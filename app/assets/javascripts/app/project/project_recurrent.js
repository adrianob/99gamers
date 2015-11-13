App.views.Project.addChild('ProjectSubscriptions', _.extend({
  el: '#project_subscriptions',

  activate: function(){
    this.filter = {was_confirmed: true};
    this.setupPagination(
      this.$("#subscriptions-loading img"),
      this.$("#load-more"),
      this.$(".results"),
      this.$el.data('path')
    );
    this.parent.on('selectTab', this.fetchPage);
  },

  events:{
    "click #load-more" : "loadMore"
  }

}, Skull.Pagination));

