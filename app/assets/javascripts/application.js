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
//= require readmore
//= require turbolinks
//
//= require vendor/jquery-ui-widget
//= require vendor/redactor
//
//= require manage_repeating_fields
//= require manage_repeating_sections
//= require nd_ldap_lookup
//= require ulra
//
//= stub vendor/modernizr

(function($) {
  'use strict';

  var adjustRequiredAttachements = function(){
    var attachementControl = $('#work_files');
    if ( attachementControl.size() > 0 ){
      attachementControl
        .removeClass('required')
        .removeAttr('required');
    }
  };

  var adjustRequiredCollaborators = function(){
    var collaboratorControl = $('.repeat');
    if ( collaboratorControl.size() > 0 ){
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
		$('.abstract').readmore({
			speed: 75,
			collapsedHeight: 200,
			lessLink: '<a href="#">Read less</a>'
		});
  };

  $(document).ready(ready);
  $(document).on('page:load', ready);
}(jQuery));
