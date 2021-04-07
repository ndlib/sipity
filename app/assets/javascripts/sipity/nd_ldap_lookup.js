/*!
* People Search
* Based on work by Erik Runyon
*/
jQuery(function($){
  'use strict';

  function queryLdap(){
    var $button = $('#people-search-button'),
        $icon = $button.find('i'),
        query = $('#submission_window_advisor_name').val(),
        api = "//www3.nd.edu/~webdev/utilities/ldap/?callback=?",
        $results = $('#people-search-results'),
        error = '<p>Error!</p>'
    ;
    if(query.length >= 2){
      $button.prop('disabled', true);
      $icon.removeClass('icon-search').addClass('icon-arrows animate-spin');
      $.getJSON( api, {
        q: query
      })
      .done(function(response) {
        $button.prop('disabled', false);
        $icon.removeClass('icon-arrows animate-spin').addClass('icon-search');
        if(response.response === 'success'){
          showResults(response.data);
        } else {
          $results.html(error);
        }
      })
      .fail(function() {
        $results.html(error);
      })
      ;
    } else {
      $results.html('Error: A search must be at least two characters in length.');
    }
  }

  function showResults(data){
    var $results = $('#people-search-results'),
        output = '<ul class="inline-search-results">'
    ;
    $.each(data, function(){
      var item = this;
      var name = (item.formal_name) ? item.formal_name : item.fullname;
      output += '<li><a href="javascript:void(0);" class="result-selector"><b class="person-name">'+ name +'</b> ';
      if(item.affiliation_primary.length > 0){ output += '<span class="person-primary-affiliation">('+ item.affiliation_primary +')</span> '; }
      output += '<ul class="person-details">';
      output += itemList(item.title, 'person-title');
      output += itemList(item.dept, 'person-dept');
      if(item.id){ output += '<li class="person-netid-field">NetID: <span class="person-netid">' + item.id + '</span></li>'; }
      output += '</ul></a></li>';
    });
    output += '</ul>';
    if(data.length === 0){ output = '<p>No results found.</p>'; }
    $results.html(output);
  }

  function itemList(item, listClass){
    var output = '';
    if(item && item.length > 0){
      output = '<li><ul class="'+ listClass +'">';
      $.each(item, function(){
        output += '<li>'+ this +'</li>';
      });
      output += '</ul></li>';
    }
    return output;
  }

  function selectResult(e){
    var $target = $(e.target),
        $result = []
    ;
    // Pressing 'Enter' when a search result has focus returns the result selector link
    // Clicking a result returns a child element
    if ($target.hasClass('result-selector')) {
      $result = $target;
    } else {
      $result = $target.parents('.result-selector');
    }

    var name = $('.person-name', $result).text(),
        netid = $('.person-netid', $result).text()
    ;
    $('#people-search-results').empty();
    $('#submission_window_advisor_name').val(name);
    $('#submission_window_advisor_netid').val(netid).focus();
  }

  function ready(){
    var $formControls = $('.submission_window_advisor_name'),
        $searchInput = $('#submission_window_advisor_name')
    ;
    $formControls.append('<div id="people-search-results"></div>');
    $('.controls', $formControls).append('&nbsp;<a href="javascript:void(0);" class="btn btn-default" id="people-search-button"><i></i>Look up NetID</a>');
    $searchInput
      .on('keypress', function(e){
        if (e.keyCode === 13){
          e.preventDefault();
          queryLdap();
        }
      })
      .attr('placeholder', 'Name');

    $('#people-search-button').on('click', function(e){
      e.preventDefault();
      queryLdap();
    });

    $('#people-search-results').on('click', 'a', function(e) {
      e.preventDefault();
      selectResult(e);
    });
  }

  $(document).ready(ready);
  $(document).on('page:load', ready);
});
