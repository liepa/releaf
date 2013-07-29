//= require ../3rd_party/jquery.fancybox.js
//= require ../lib/url_builder

jQuery(document).ready( function()
{
    var ajaxbox_link_selector = 'a.ajaxbox';
        
    var xhr;
    
    var body = jQuery('body');        

    var open_ajax_box = function( params )
    {
        var fancybox_params = 
        {
            autoDimensions    : true,
            autoScale         : true,
            centerOnScroll    : true,
            scrolling         : 'no',
            padding           : 0,
            overlayColor      : '#000000',
            overlayOpacity    : 0.5,
            closeBtn          : false,
            afterShow        : function()
            {
                this.inner.addClass('ajaxbox-inner');
                
                // insert close button if header exists and box is not modal
                if (!params.modal)
                {
                    var header = this.inner.find('.body .header').first();
                    if (header.length > 0)
                    {
                        var close_icon   = jQuery('<i />').addClass('icon-remove icon-large');
                        var close_button = jQuery('<button />').attr('type', 'button').addClass('button secondary close only-icon').append(close_icon);
                        close_button.on('click', function()
                        {
                            close_ajax_box();
                        })
                        header.append( close_button );
                    }
                }
               
                // focus on cancel button in footer if found
                var cancel_button = this.inner.find('.body .footer .button[data-type="cancel"]').first();
                if (cancel_button.length > 0)
                {
                    cancel_button.bind('click', function()
                    {
                        body.trigger('ajaxboxclose');
                        return false;
                    });
                    cancel_button.focus();
                }
                
                this.inner.trigger('contentloaded');      
                
                this.inner.trigger('ajaxboxdone');
                
            },
            beforeClose  : function()
            {
                
                this.inner.trigger('ajaxboxbeforeclose');
            }
        }
        
        if (params.modal)
        {
            fancybox_params.closeClick   = false;
            fancybox_params.helpers     = { overlay: { closeClick: false } };            
        }
        
        fancybox_params.content = params.content;
        jQuery.fancybox( fancybox_params );        
        return;
    }
    
    var close_ajax_box = function()
    {
        jQuery.fancybox.close();   
    }
    
    
    body.on('ajaxboxinit', function(e)
    {
        var target = jQuery(e.target);

        // init links 
        var links = (target.is(ajaxbox_link_selector)) ? target : target.find(ajaxbox_link_selector);
        
        links.on('click', function()
        {
            var link = jQuery(this);
            
            var params = 
            {
                url     : new url_builder( link.attr('href') ).add( { ajax: 1 } ).getUrl(),
                modal   : (link.attr('data-ajaxbox-modal') == '1')
            };

            link.trigger('ajaxboxopen', params);
            
            return false;
        });

    });
    
    body.on('ajaxboxopen', function(e, params)
    {
        // params expects either url or content
        if ('content' in params)
        {
            open_ajax_box( params );
        }
        else if ('url' in params)
        {
            if (xhr)
            {
                xhr.abort();
            }

            xhr = jQuery.ajax(
            {
                url:   params.url,
                type: 'get',
                success: function( data ) 
                {
                    params.content = data;
                    open_ajax_box( params );
                }
            });
        }
    });

    body.on('ajaxboxclose', function(e)
    {
        close_ajax_box();
    });


    // attach ajaxboxinit to all loaded content
    body.on('contentloaded', function(e)
    { 
        // reinit ajaxbox for all content that gets replaced via ajax
        jQuery(e.target).trigger('ajaxboxinit');
    });
    
});

