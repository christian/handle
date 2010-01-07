// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery.fn.inputFieldText = function(string) {          
    this.each(function() { 
        $(this).val(string); 
        $(this).focus(function(){ 
            if ($(this).val() == string){ 
                $(this).val('');
                $(this).css("color","#000"); 
            } 
        }); 
        $(this).blur(function(){ 
            if ($(this).val() == '' ){ 
                $(this).val(string); 
                $(this).css("color","#aaa"); 
            } 
        });     
    }); 
}