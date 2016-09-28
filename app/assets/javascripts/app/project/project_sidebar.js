App.addChild('ProjectSidebar', {
  
  el: '#project-reward-sidebar',

  events: {
    'click #toggle-goals' : 'toggleGoals',
    'click a#embed_link' : 'toggleEmbed'
  },

  toggleGoals: function(){
    this.$goals.slideToggle('slow');
    return false;
  },

  activate: function() {

    var that = this;

    this.$goals = this.$('#other-goals');
    this.$rewards = this.$('#rewards');

    $.get(that.$rewards.data('index_path')).success(function(data){
      that.$rewards.html(data);
    });

    this.$plans = this.$('#plans');

    $.get(that.$plans.data('index_path')).success(function(data){
      that.$plans.html(data);
    });
  }

});

