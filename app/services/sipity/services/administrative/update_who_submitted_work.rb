module Sipity
  module Services
    module Administrative
      # @api private
      #
      # Please Note: I have not written tests for this.  In part because I chose to add an audit (e.g. "Are you sure you want to do this?")
      class UpdateWhoSubmittedWork
        class ErrorState < RuntimeError
        end
        # @api public
        #
        # The {Sipity::Forms::SubmissionWindows::Etd::StartASubmissionForm} class calls {CommandRepository#grant_creating_user_permission_for!}
        # to assign the {Sipity::Models::Role::CREATING_USER} role (e.g., 'creating_user').
        #
        # We have had two cases in which we need to change the creating user.
        #
        # Case 1: A professor submitted it on another person's behalf.  We chose to change the professor's netID to the other person's netID.
        # This, in essence, associated the database user from one person to another.
        #
        # Case 2: The graduate school submitted this on a person's behalf.  Instead of replacing the netID (which would've cause significant
        # problems), we instead chose to change the relationships of the {Sipity::Models::Processing::Actor}.
        #
        # From a logging and provenance stand-point, Case 2 is perhaps most ideal.
        #
        # This class seeks to encode that logic.
        #
        # There are two primary functions:
        #
        # * #audit!
        # * #change_it!
        #
        # @param work [Object] An id or Sipity::Models::Work (e.g. something that can be converted via Conversions::ConvertToWork)
        # @param from_username [String] The netid of the current user that submitted
        # @param to_username [String] The netid of the user that you are assigning "submitter" status to.
        # @param role [String] The role we're going to change.
        #
        # @note This
        def initialize(work:, from_username:, to_username:, role: Sipity::Models::Role::CREATING_USER, logger: default_logger)
          self.work = work
          self.role = role
          @logger = logger
          @from_username = from_username
          @to_username = to_username
          @audited = false
        end

        attr_reader :work, :role

        def audit!
          @errors = false
          entity
          audit_from_username
          audit_to_username
          audit_work_for_from_user
          return false if @errors
          @audited = true
        end

        def audited?
          @audited
        end

        def errors?
          @errors
        end

        def change_it!
          raise ErrorState.new("First audit! this change") unless audited?
          raise ErrorState.new("There are errors in this request, run audit! for details") if errors?
          @to_user ||= User.find_or_create_by!(username: @to_username)
          move_work_role_assoication_from_user_to_user!
        end

        private

        # :nocov:
        def audit_from_username
          @from_user = User.find_by(username: @from_username)
          if @from_user
            logger.info("Found :from_username #{@from_username.inspect} for User ID=#{@from_user.id}")
          else
            logger.error("Could not find :from_username #{@from_username.inspect}")
            @errors = true
          end
        end

        def audit_to_username
          @to_user = User.find_by(username: @to_username)
          if @to_user
            logger.info("Found :to_username #{@to_username.inspect} for User ID=#{@to_user.id}")
          else
            logger.warn("Could not find :to_username #{@to_username.inspect}.  The #change_it! method will create a new user with username #{@to_username}")
          end
        end

        # Ensure that the given work is associated with the from user.
        def audit_work_for_from_user
          return false unless @from_user # short circuit assumption that we have a from user
          if entity_specific_responsibility_for(user: @from_user)
            logger.info("The from_user #{@from_user.username.inspect} has the role \"#{role}\" for the given work ID=\"#{work.id}\"")
          else
            logger.error("The from_user #{@from_user.username.inspect} does not have the role \"#{role}\" for the given work ID=\"#{work.id}\"")
            @errors = true
          end
        end
        # :nocov:

        def move_work_role_assoication_from_user_to_user!
          # Alternatively, we could call the following:
          #
          # Sipity::Services::RevokeProcessingPermission.call(entity: entity, actor: @from_user, role: role)
          # Sipity::Services::GrantProcessingPermission.call(entity: entity, actor: @to_user, role: role)
          record = entity_specific_responsibility_for(user: @from_user)
          record.update!(actor: Conversions::ConvertToProcessingActor.call(@to_user))
        end

        def entity_specific_responsibility_for(user:)
          esr = Sipity::Models::Processing::EntitySpecificResponsibility.arel_table
          sr = Sipity::Models::Processing::StrategyRole.arel_table

          Sipity::Models::Processing::EntitySpecificResponsibility.where(
            entity: entity,
            actor: Conversions::ConvertToProcessingActor.call(user),
          ).where(
            esr[:strategy_role_id].in(
              sr.project(sr[:id]).where(
                sr[:role_id].eq(role.id).and(
                  sr[:strategy_id].eq(entity.strategy_id)
                )
              )
            )
          ).first
        end

        def work=(input)
          @work = Conversions::ConvertToWork.call(input)
        end

        def entity
          @entity ||= Conversions::ConvertToProcessingEntity.call(work)
        end

        def role=(input)
          @role = Conversions::ConvertToRole.call(input)
        end

        # :nocov:
        def default_logger
          Logger.new(STDOUT)
        end
        # :nocov:
      end
    end
  end
end
