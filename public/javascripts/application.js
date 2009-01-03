// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

file_upload = function(form, callback){
  if (callback === undefined || callback === '') {
    callback = function(data){};
  }

  $(form).submit(function(){
    var frame_id = 'UploadFrame' + new Date().getTime();

    var io = $('<iframe id="' + frame_id + '" name="' + frame_id + '" />');
    io.css('position', 'absolute');
    io.css('top', '-1000px');
    io.css('left', '-1000px');

    io.load(function(){
      var data = $('#' + frame_id).contents().find('body').html();
      callback(data);

      setTimeout("$('#" + $(this).attr('id') +"').remove()", 5000)
    });

    io.appendTo('body');
    $(form).attr('target', frame_id);
  });
};
