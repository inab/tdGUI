

/**
 * This is the model to keep the data returned by calls to proteinInfo service
 */
Ext.define('TDGUI.model.AttributesTarget', {
  extend:'Ext.data.Model',

  fields:[
    'name', // target_name for conceptWiki or /uniprot/protein/recommendedname/fullname
    'concept_uuid',
    'concept_uri',
    'uniprot_acc', // this is /uniprot/entry/accession
    'uniprot_id' // this is /uniprot/entry/name
  ]
});