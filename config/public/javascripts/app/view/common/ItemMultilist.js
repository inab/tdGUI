




Ext.define ('TDGUI.view.common.ItemMultilist', {
  requires: ['TDGUI.store.ListTargets', 'Ext.ux.form.MultiSelect'],
	extend: 'Ext.panel.Panel',
  alias: 'widget.tdgui-item-multilist',

	border: false,
	frame: false,

	store: undefined,
	displayField: undefined,
  valueField: undefined,
  layout: 'anchor',
  listName: '',


	initComponent: function () {
		var me = this

		this.items = [{
      fieldLabel: me.listName,
      labelAlign: 'top',
      labelSeparator: '',
      labelCls: 'targetlist-font-label',

			xtype: 'multiselect',
			msgTarget: 'none',
//			fieldLabel: 'Multiselect',
			name: 'multiselect',
			id: 'multiselect-field',
//			allowBlank: false,
			anchor: '100%',
      border: false,
      height: 400,

      store: me.store,
      displayField: me.displayField,
      valueField: me.valueField

      /*
			store: [
				[123, 'One Hundred Twenty Three'],
				['1', 'One'],
				['2', 'Two'],
				['3', 'Three'],
				['4', 'Four'],
				['5', 'Five'],
				['6', 'Six'],
				['7', 'Seven'],
				['8', 'Eight'],
				['9', 'Nine'],
				['5', 'Five'],
				['6', 'Six'],
				['7', 'Seven'],
				['8', 'Eight'],
				['9', 'Nine']
			],
			value: ['3', '4', '6']
      */
		}]

		this.dockedItems = [{
			xtype: 'toolbar',
			dock: 'bottom',
			ui: 'footer',

			items: ['->', {
				xtype: 'button',
				text: 'Clear',
				handler: function () {
					var list = me.down('multiselect')
          var myStore = list.store
          myStore.removeAll()
				}
			}, {
				xtype: 'button',
				text: 'Remove',
				handler: function () {
					var list = me.down('multiselect')
					var vals = list.getValue()
					var myStore = list.store
// console.info ('store size before: '+myStore.count())

					Ext.each (vals, function (val, index, theVals) {
						var rec  = myStore.findRecord(list.valueField, val)
						myStore.remove (rec)
					})
// console.info ('store size afterwards: '+myStore.count())
				}
			}]
		}]

		this.callParent(arguments)
	},



  getStore: function () {
    return this.store
  },



  getStoreItems: function (dataIndex) {
    var records = this.store
    var items = records.collect(dataIndex)

    return items
  },


  getStoreObject: function (field, value) {
    var rec = this.store.findRecord(field, value)

    return rec
  },


  addDockedItem: function (newComp) {
    var me = this
    var dockedTb = this.getDockedItems('')[0]
    dockedTb.add(newComp)
  }


})