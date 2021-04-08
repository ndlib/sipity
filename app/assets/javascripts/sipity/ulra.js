jQuery(function($){
  'use strict';
  function ready() {
    var $checkbox = $('.with-followup-questions-js .submitted-for-publication-js'),
        $followupQuestions = $checkbox.parents(".with-followup-questions-js").children('.followup-questions-to-submitted-for-publication')
    ;
    if ($checkbox[0] !== undefined && $checkbox[0].checked !== true) {
      $followupQuestions.hide();
    }
    $('.with-followup-questions-js .submitted-for-publication-js').on('change', function() {
      $followupQuestions.toggle();
    });
  }
  $(document).ready(ready);
  $(document).on('page:load', ready);
});
