App.addChild('DashboardGoals', {
  el: '#dashboard-goals-tab',

  events:{
    "cocoon:after-insert #goals": "reloadSubViews"
  },

  activate: function() {
    this.$goals = this.$('#dashboard-goals #goals');
  },

  reloadSubViews: function(event, insertedItem) {
    this.goalForm.undelegateEvents();
    this._goalForm = null;
    this.goalForm;
  },

});

App.views.DashboardGoals.addChild('goalForm', _.extend({
  el: '.goal-card',

  events: {
    'blur input' : 'checkInput',
    'blur textarea' : 'checkInput',
    'submit form' : 'validate',
    "click .goal-close-button": "closeForm",
    "click .fa-question-circle": "toggleExplanation",
    "click .show_goal_form": "showgoalForm"
  },

  activate: function(){
    this.setupForm();
  },

  toggleExplanation: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.parent().next('.goal-explanation').toggle();
  },

  closeForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.closest('.card-edition').hide();
    $target.closest('.card-edition').parent().find('.card-persisted').show();
  },

  showgoalForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    this.$($target.data('parent')).hide();
    this.$($target.data('target')).show();
  }

}, Skull.Form));
