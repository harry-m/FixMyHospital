$(document).ready(function(){
  block_count = $('.hospital_block').size();
  if(block_count > 1) {
    current_block = 1;

    $('#hospitals').append('<a id="next_block" href="#">Show more results</a>')

    $('#next_block').click(function(){
      current_block += 1;

      $('#block_' + current_block).show();
      $('#next_block').attr('href', '#block_' + current_block)

      if(current_block == block_count) {
        $('#next_block').remove();
        $('#hospitals').append('<p class="nomore">(No more results)</p>');
      }
    });

    for(block = 2; block <= block_count; block++) {
      $('#block_' + block).hide()
    }
  }

});
