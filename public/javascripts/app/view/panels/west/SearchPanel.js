

Ext.define ('TDGUI.view.panels.west.SearchPanel', {
	extend: 'Ext.panel.Panel',
	alias: 'widget.tdgui-west-search',
	requires: ['TDGUI.view.dropdowns.tdgui.ConceptWikiProteinLookup',
             'TDGUI.view.dropdowns.tdgui.ButtonComboProteinLookup',
             'TDGUI.view.common.Textarea',
             'TDGUI.view.panels.PanelButtons'],

//	region: 'west',
  collapsible: true,
  title: 'Search center',
  split: true,
  width: '20%',
  minWidth: 300,
  minHeight: 200,
  border: false,

  defaults: {
    border: false
  },
//            html: 'west<br>I am floatable',
/*
Example snippet:
this.items = [
    grid = Ext.widget('dynamicgrid')
];
grid.buttonRender(['new', 'edit', 'filter', 'delete', 'load', 'exporter']);
this.callParent(arguments);
*/


  initComponent: function () {
  	var me = this
console.info ("Initializing panels.west.SearchPanel + Tabs comp...")

//    me.items = [this.createTabs()]
    me.items = [this.createSearchTab(), this.createRetrievingTab()]
    me.callParent (arguments)
  }, // EO initComponent




// METHODS TO CREATE COMPONENTS ////////////////////////////////////////////////////
  createLabel: function () {
    this.exampleLabel = Ext.create ('Ext.form.Label', {
      text: 'Click for examples!!!',
      margin: 10,

      listeners: {
        'afterrender': function (thisCmp, objOpts) {

          var lbEl = thisCmp.getEl()
          lbEl.on ('click', function() {
            thisCmp.fireEvent ('click', thisCmp)
          })
        }
      },

      initComponent: function () {
        this.addEvents ('click')

        this.callParent (arguments)
      }
    })
    return this.exampleLabel
  },



  createSearchTab: function () {
    this.searchTab = Ext.create ('Ext.panel.Panel', {
//      title: 'Search',
//      renderTo: Ext.getBody(),
//      width: 400,
//      height: 200,
      bodyPadding: '15 0 10 0',
      border: false,

//      closable: true,

      items: [this.createLabel(), {
//          title: 'Search',
        frameHeader: false,
        border: false,
//        bodyPadding: 5,
        padding: '5 10 10 10', // padding for this panel
        layout: 'column',
//          style: 'background-color: lightblue;',

        items: [{
//            xtype: 'tdgui-conceptwiki-protein-lookup',
            xtype: 'tdgui-button-combo-proteinlookup',
            columnWidth: .85,
            enableKeyEvents: true
          }, {
            xtype: 'button',
            text: ' GO ',
            columnWidth: .15,
            action: 'query-protein-info',
//            disabled: false
        }] // EO items

      }]
    })

    return this.searchTab
  },




  createTextarea: function () {
    this.textareaCode = Ext.widget ('tdgui-textarea', {
      anchor: '100% 80%',
      value: 'Q13362\nP12345\nP0AEN3\nP0AEN2\nP0AEN1',
//      disabled: true
    })

    return this.textareaCode
  },



  createRetrievingTab: function () {
    var me = this
    this.retrievingTab = Ext.create ('Ext.panel.Panel', {
//      title: 'Retrieve',
//      width: 400,
      height: 200,
      padding: '15 10 10 10',
      layout: 'anchor',
      frameHeader: false,
      border: false,
//      closable: true,

      items: [
        this.createTextarea(),
        me.retrievingButtons = Ext.widget ('tdgui-panelbuttons', {
          anchor: '100%',
          rightButtonName: ' GO ',
          leftButtonName: 'Reset'
        })
      ]
    })

    return this.retrievingTab
  },



// NOT used currently, as all search boxes are place on a single panel
  createTabs: function () {
    this.tabsSearch = Ext.create ('Ext.tab.Panel', {
      activeTab: 1,
      width: '100%',
//      width: 400,

      items: [
        this.createSearchTab(),
        this.createRetrievingTab()
        /*
        {
          title: 'Retrieve',
          html : 'Another one'
      }*/] // EO items
    }) // EO tabsSearch

    return this.tabsSearch
  }


// items: theWestItems
})