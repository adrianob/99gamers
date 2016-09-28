App.addChild('Project', _.extend({
  el: 'body[data-action="show"][data-controller-name="projects"]',

  events: {
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
    this.$container = $(".project-about");
    
    this.route('about');
    this.route('posts');
    this.route('contributions');
    this.route('subscriptions');
    this.route('comments');
    this.route('edit');
    this.route('reports');
    this.route('metrics');
    
    this.setupResponsiveIframes(this.$container);

  $('#gallery-1').royalSlider({
    fullscreen: {
      enabled: false,
      nativeFS: false
    },
    controlNavigation: 'thumbnails',
    autoScaleSlider: true, 
    autoScaleSliderWidth: 960,     
    autoScaleSliderHeight: 640,
    loop: false,
	transitionType: 'fade',
    imageScaleMode: 'fill',
    navigateByClick: false,
    numImagesToPreload:2,
    arrowsNav:false,
    arrowsNavAutoHide: true,
    arrowsNavHideOnTouch: true,
    keyboardNavEnabled: true,
    fadeinLoadedSlide: true,
    globalCaption: false,
    globalCaptionInside: false,
    thumbs: {
      appendSpan: true,
      firstMargin: false,
	  spacing: 5,
	  autoCenter: true,
	  drag: false,
    },
	video: {
      autoHideArrows:true,
      autoHideControlNav:false,
      autoHideBlocks: true
    }, 	 
  });
  },

  toggleWarning: function(){
    this.$warning.slideToggle('slow');
    return false;
  },

  toggleEmbed: function(){
    this.loadEmbed();
    this.$embed.slideToggle('slow');
    return false;
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });
      var tabs = ['metrics_link'];

      if($.inArray($tab.prop('id'), tabs) !== -1) {
        $('#project-sidebar').hide();
      } else {
        $('#project-sidebar').show();
      }
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.is(':empty')) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs, Skull.UI_helper));
