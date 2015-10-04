App.addChild('DashboardPlans', {
  el: '#dashboard-plans-tab',

  activate: function() {
    this.$plans = this.$('#dashboard-plans #plans');
    this.sortablePlans();
  },

  sortablePlans: function() {
    that = this;
    this.$plans.sortable({
      axis: 'y',
      placeholder: "ui-state-highlight",
      start: function(e, ui) {
        return ui.placeholder.height(ui.item.height());
      },
      update: function(e, ui) {
        var csrfToken, position;
        position = that.$('#dashboard-plans .nested-fields').index(ui.item);
        csrfToken = $("meta[name='csrf-token']").attr("content");
        update_url = $(ui.item).find('.card-persisted').data('update_url');
        return $.ajax({
          type: 'POST',
          url: update_url,
          dataType: 'json',
          headers: {
            'X-CSRF-Token': csrfToken
          },
          data: {
            plan: {
              row_order_position: position
            }
          }
        });
      }
    });
  },

});

App.views.DashboardPlans.addChild('PlanForm', _.extend({
  el: '.plan-card',

  events: {
    'blur input' : 'checkInput',
    'blur textarea' : 'checkInput',
    'submit form' : 'validate',
    "click .plan-close-button": "closeForm",
    "click .fa-question-circle": "toggleExplanation",
    "click .show_plan_form": "showPlanForm"
  },

  activate: function(){
    this.setupForm();
  },

  toggleExplanation: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.parent().next('.plan-explanation').toggle();
  },

  closeForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.closest('.card-edition').hide();
    $target.closest('.card-edition').parent().find('.card-persisted').show();
  },

  showPlanForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    this.$($target.data('parent')).hide();
    this.$($target.data('target')).show();
  }

}, Skull.Form));

