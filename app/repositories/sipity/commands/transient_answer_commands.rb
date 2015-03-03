module Sipity
  # :nodoc:
  module Commands
    # Responsible for applying various transient answers to an entity. In some
    # cases additional commands may fire.
    #
    # @see Sipity::Models::TransientAnswer
    module TransientAnswerCommands
      def handle_transient_access_rights_answer(entity:, answer:)
        # REVIEW: Is a transient answer necessary for the the "trivial" answers?
        # That is to say the ones that write the more permanent "AccessRights"
        transient_answer = Models::TransientAnswer.create!(
          entity: entity, question_code: Models::TransientAnswer::ACCESS_RIGHTS_QUESTION, answer_code: answer
        )
        # REVIEW: There is some serious knowledge related to what is happening
        #   here. Would it make sense to have a container for TransientAnswers
        #   then within that container (i.e. question based) and send a
        #   message to that container regarding application of the answer.
        case answer
        when 'open_access', 'restricted_access', 'private_access'
          Models::AccessRight.create!(entity: entity, access_right_code: answer)
        end
        transient_answer
      end
    end
  end
end
