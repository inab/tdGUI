Ext.define('TDGUI.controller.SearchPanel', {
  extend:'Ext.app.Controller',
//	models: ['Target'],
//	stores: ['Targets'],
  views:['panels.west.SearchPanel', 'panels.BorderCenter'],

  /*refs: [{
   ref: 'targetPanel',                       º
   selector: 'TargetPanel'
   }, {
   ref: 'formView',
   selector: 'TargetByNameForm'
   }, {
   ref: 'submitButton',
   selector: '#TargetByNameSubmit_id'

   }],*/

  refs:[
    {
      ref:'protLookup', // I get this.getProtLookup ()
      selector:'panel tdgui-chkbox-combo-proteinlookup' // proteinLookup combo
    },
    {
      ref:'examplesLabel', // I get this.getExamplesLabel
      selector:'tdgui-west-panel > panel > label' // label over the proteinLookup combo
    },
    {
      ref:'contentPanel',
      selector:'viewport > tdgui-border-center' // the content area
    },
    {
      ref:'btnProteinLookup',
      selector:'viewport > panel > panel > button'
    },
    {
      ref:'accTextarea', // accessions textarea
      selector:'panel > tdgui-textarea'
    },
    {
      ref:'itemList', // accessions textarea
      selector:'panel > tdgui-item-multilist'
    }
  ],


  init:function () {

    console.info('SearchPanel controller initializing... ')
    this.control({
      'TargetByNameForm button[action=query_target_by_name]':{
        click:this.submitQuery
      },

      'TargetByNameForm conceptWikiProteinLookup':{
        select:this.enableSubmit
      },

      'tdgui-west-search label':{
        click:this.labelClick // a window, tooltip or whatever has to be raised with ex
      },

      'tdgui-chkbox-combo-proteinlookup':{
        focus:this.clickLookup,
        keyup:this.keepKeyup
      },

      'tdgui-textarea':{
        click:this.textareaClick
//        afterrender: this.checkTxt
      },

      'tdgui-west-search > panel > panel > toolbar > button[text=Search]':{ // see buttons on Panel
        click: this.retrieveBtnClick
      },

      'tdgui-west-search > panel button[action=query-protein-info]':{
//        click: this.clickGoProteinInfo
        click:this.clickAddProteins
      }

    });
  },


  clickLookup:function () {
    console.info('*** focus on lookup')
  },


  keepKeyup:function (comp, ev, opts) {
    comp.inputString = ev.target.value
  },


  retrieveBtnClick:function (btn, ev, opts) {
//    var txtArea = btn.up('tdgui-west-search').down('tdgui-textarea')
//    var uniprotIds = txtArea.getRawValue().split('\n').join(',')
    var me = this
    var uniprotIds = this.getItemList().getStoreItems()

    Ext.History.add('!xt=tdgui-multitargetpanel&qp=' + uniprotIds)

  /*
    if (btn.getId() == 'panelBtnLeft')
      txtArea.setValue('')
    else
      Ext.History.add('!xt=tdgui-multitargetpanel&qp=' + uniprotIds);

   *
     Ext.Ajax.request({
     url: 'tdgui_proxy/multiple_entries_retrieval',
     method: 'GET',
     params: {
     entries: uniprotIds
     },

     success: function(response){
     var text = response.responseText
     // console.info ("Got: "+text)
     var testPanel = Ext.widget ('panel', {
     title: 'Test Request',
     html: text,
     closable: true
     })
     me.getContentPanel().add (testPanel)
     // process server response here
     }
     });
     */

  },


  clickAddProteins:function (btn, ev, opts) {
    var protLookup = this.getProtLookup()
    var listChoices = protLookup.getSelectedItems()
    /*    var filteredStore = protLookup.store.filter ([{
     filterFn: function (item) { return if in list }
     }]) */

    var labels = new Array()
    Ext.each(listChoices, function (choice, index, theChoices) {
      if (choice.concept_url.indexOf('uniprot') == -1) {
        var label = choice.concept_label
        var speciesIndex = label.indexOf('(')
        if (speciesIndex != -1)
          label = label.substring(0, speciesIndex - 1)

        labels.push(label)
      }
    })

    var listStore = this.getItemList().getStore()
    Ext.Array.each (labels, function (item, number, theLabels) {

      if (item.indexOf ('uniprot') == -1) { // if uniprot, dont go there again

        Ext.Ajax.request ({
          url:'/tdgui_proxy/get_uniprot_by_name',
          method:'GET',
          params:{
            label: item
          },

          failure:function (resp, opts) {
            console.info('ajax failed for item number: ' + number + ' -> ' + resp.responseText)
          },

          success:function (resp, opts) {
            console.info('success for number ' + number + ' -> ' + resp.responseText)

            var jsonResp = Ext.JSON.decode(resp.responseText)
            var listItem = {
             name: item, // target_name for conceptWiki or /uniprot/protein/recommendedname/fullname
             concept_uuid: listChoices[number].concept_uuid,
             concept_uri: listChoices[number].concept_uri,
             uniprot_acc: jsonResp.accessions,
             uniprot_id: jsonResp.accessions,
             uniprot_name: jsonResp.name
            }

            if (jsonResp === {})
              console.info ("Nothing found for: "+item)
            else {
              var target = Ext.create('TDGUI.model.ListTarget', listItem)
              listStore.add(target)
            }
          }
        })
      } // EO if
    })


    var txtArea = protLookup.up('panel').up('panel').up('panel').down('tdgui-textarea')

/*
    var listTargets = txtArea.getRawValue().split('\n')
    list = listTargets.concat(list)
    txtArea.setRawValue('')
    Ext.each(listChoices, function (item, index, listItself) {
      txtArea.addLine(item)
    })
*/
//    console.info('Added: ' + list.join(','))
  },



  clickGoProteinInfo:function (btn, ev, opts) {
    console.info('clickGoProteinInfo...')
    var conceptLookup = this.getProtLookup()
    var selOption = conceptLookup.getValue()
    if (selOption != null && selOption != "") {
      console.info('button clicked for: ' + selOption)
    }

    Ext.History.add('!xt=tdgui-targetinfopanel&qp=' + selOption)
  },


  labelClick:function () {
    console.info('SearchPanel.controller: got click event from label ' + this.getExamplesLabel())
//						this.getExamplesLabel().setText ('Its ok'))
  },


  textareaClick:function () {
//    console.info ('click event on textarea with content: '+this.getAccTextarea().getValue())
  },


  checkTxt:function (comp, opts) {
    console.info('fucking textarea: disabled?' + comp.isDisabled())
  },

  enableSubmit:function () {
    var form = this.getFormView();
    var button = this.getSubmitButton();
    button.enable();
  },


  submitQuery:function (button) {
    button.disable();
    var tp = this.getTargetPanel();
    tp.startLoading();

    var form = this.getFormView();
    var target_uri = form.getValues().protein_uri;

    Ext.History.add('TargetByNameForm=' + target_uri);
  }
});
