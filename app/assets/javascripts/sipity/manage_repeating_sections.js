// This widget manages the adding and removing of repeating fields.
// There are a lot of assumptions about the structure of the classes and elements.
// These assumptions are reflected in the MultiValueInput class.
//
(function($){
  'use strict';

  $.widget( "sipity.manage_sections", {
    options: {
      change: null,
      add: null,
      remove: null
    },

    _create: function() {
      this.element.addClass("managed");
      $('.repeat', this.element).addClass("input-append");
      if( this.element.data('manage_sections-label') ){
        this.label_text = this.element.data('manage_sections-label');
      } else {
        this.label_text = "Add";
      }
      this.adder = $("<button class=\"btn btn-success add\" id=\"section_add_button\"><i class=\"icon-white icon-plus\"></i><span>" + this.label_text + "</span></button>");
      this.remover = $("<button class=\"btn btn-danger remove\"><i class=\"icon-white icon-minus\"></i><span>Remove</span></button>");
      this.tableControls = $('.table-controls', this.element);
      this.cannotAddNotification = $('<div class="alert alert-warning warning">You cannot add multiple empty entries.</div>');
      this.fieldIndex = $('.repeat', this.element).length;

      $('.repeat:not(:last-child) .row-controls', this.element).append(this.remover);
      $('.table-controls', this.element).append(this.adder);

      this._on( this.element, {
        "click .remove": "remove_from_list",
        "click .add": "add_to_section_list"
      });

      var $last_line = $('.repeat', this.element).last();
      var $last_element_val = $last_line.children('td.name').first().children('div').children('input').val();
      if( $last_element_val ){
        $( '#section_add_button').trigger( 'click' );
      }
    },

    add_to_section_list: function( event ) {
      event.preventDefault();

      var $activeField = $('.repeat:last', this.element), // Assume we are always working with the bottom-most row
          $activeFieldControls = $activeField.children('.row-controls'),
          $lastNameField = $activeField.children('td.name').first().children('div').children('input'),
          $newField = $activeField.clone(),
          $listing = $activeField.parent(),
          $removeControl = this.remover.clone(),
          $warning = this.tableControls.children('.warning'),
          warningCount = $warning.length;

      if ($lastNameField.val() === '') {
        if (warningCount === 0) {
          this.tableControls.prepend(this.cannotAddNotification);
        }
      } else {
        $warning.remove();

        this.fieldIndex += 1;
        var rowNumber = this.fieldIndex;

        $('.add', $activeFieldControls).remove();
        $('.remove', $activeFieldControls).remove();
        $activeFieldControls.prepend($removeControl);

        var $nameFieldCell = $newField.children('td.name')
                       .first()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_name')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][name]');

        var $roleFieldCell = $newField
                       .children('td.role')
                       .last()
                       .children('div')
                       .children('select')
                       .attr('id', 'work_collaborators_attributes_' + rowNumber + '_role')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][role]');

        var $revieweOptionCell = $newField
                       .children('td.review')
                       .last()
                       .children('div')
                       .children('select')
                       .attr('id', 'work_collaborators_attributes_' + rowNumber + '_responsible_for_review')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][responsible_for_review]');

        var $idFieldCell = $newField
                       .children('td.contact-information')
                       .first()
                       .children('span')
                       .first()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_netid')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][netid]');

        var $emailFieldCell = $newField
                       .children('td.contact-information')
                       .first()
                       .children('span')
                       .last()
                       .children('div')
                       .children('input')
                       .attr('id', 'work_collaborators__attributes_' + rowNumber + '_email')
                       .attr('name', 'work[collaborators_attributes][' + rowNumber + '][email]');

        $nameFieldCell.val('');
        $roleFieldCell.val('');
        $revieweOptionCell.children("option[value='No']").attr("selected","selected");
        $idFieldCell.val('');
        $emailFieldCell.val('');

        $activeField.children('button').remove();
        $listing.append($newField);
        $('.remove', $newField).remove();
        $nameFieldCell.first().focus();
        this._trigger("add");
      }
    },

    remove_from_list: function( event ) {
      event.preventDefault();
      this.tableControls
        .children('.warning')
        .remove();

      var parent = $(event.target).parents('.repeat');
      var parent_sibling = $(parent.next());

      // In the case of fields_for, a hidden input field is added that allows for
      // passing the object identifier as part of the form submission. This also
      // needs to be removed when we remove the repeating field.
      //
      // This is a kludge type hack in that what is really needed is to look at the
      // input fields of the parent, find its DOM-ID prefix (i.e. For work_0_name, the
      // prefix would be work_0). Then find the corresponding inputs with that same prefix
      // and _id (i.e. work_0_id); We would then delete those elements.
      if( parent_sibling.prop('type') === 'hidden' ) {
        parent_sibling.remove();
      }
      parent.remove();

      this._trigger("remove");
    },

    _destroy: function() {
      this.actions.remove();
      $('.repeat', this.element).removeClass("input-append");
      this.element.removeClass( "managed" );
    }
  });
})(jQuery);
