// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//
//= require bootstrap-sprockets
//
//= require vendor/jquery-ui-widget
//= require vendor/redactor
//= require sipity/redactor_field
//
//= require sipity/manage_repeating_fields
//= require sipity/manage_repeating_sections
//= require sipity/nd_ldap_lookup
//= require sipity/ulra
//
//= stub vendor/modernizr

(function($) {
  'use strict';

  var adjustRequiredAttachements = function(){
    var attachementControl = $('#work_files');
    if ( attachementControl.length > 0 ){
      attachementControl
        .removeClass('required')
        .removeAttr('required');
    }
  };

  var adjustRequiredCollaborators = function(){
    var collaboratorControl = $('.repeat');
    if ( collaboratorControl.length > 0 ){
      collaboratorControl.last().children('td.name').first().children('div').children('input').first().removeClass('required').removeAttr('required');
      collaboratorControl.last().children('td.role').first().children('div').children('select').first().removeClass('required').removeAttr('required');
    }
  };

	var disableSubmitOnClick = function(){
		var submitButton = $(":input[type='submit']");
		submitButton.attr('data-disable-with', 'Please wait...');
	};

  var ready = function(){
    $('.table.collaborators').manage_sections();
    $('.multi-value.control-group').manage_fields();
    adjustRequiredCollaborators();
    adjustRequiredAttachements();
		disableSubmitOnClick();
    $('.help-icon').tooltip();
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
}(jQuery));
