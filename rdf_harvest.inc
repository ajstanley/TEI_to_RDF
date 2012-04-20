<?php

function tei_input_form(&$form_state) {

  $form = array();
  $form['#attributes'] = array('enctype' => 'multipart/form-data');
  $form['file_upload'] = array(
    '#type' => 'file',
    '#title' => t('Upload TEI xml'),
    '#size' => 48,
    '#description' => t('Upload file'),
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#weight' => 10,
    '#value' => 'Ingest TEI'
  );

  return $form;
}

function tei_input_form_validate($form, &$form_state) {

  $fieldName = 'file_upload';
  if (isset($_FILES['files']) && is_uploaded_file($_FILES['files']['tmp_name'][$fieldName])) {
    $file = file_save_upload($fieldName);
    if (!$file) {
      form_set_error($fieldName, 'Error uploading file.');
      return;
    }
    $form_state['values']['file'] = $file->filepath;
  }
}

function tei_input_form_submit($form, &$form_state) {

  $file = $form_state['values']['file'];
  $tei_string = file_get_contents($file);
  $rdf_string = create_rdf_from_tei($tei_string);
}

function create_rdf_from_tei($tei_string) {

  $path = drupal_get_path('module', 'interedition');

  if ($tei_string == NULL || strlen($tei_string) < 5) {
    return " ";
  }

  try {
    $proc = new XsltProcessor();
  } catch (Exception $e) {
    drupal_set_message(t('@e', array('@e' => check_plain($e->getMessage()))), 'error');
    return " ";
  }

  $xsl = new DomDocument();
  $xsl->load($path . '/xslt/tei_to_rdf.xsl');
  $input = new DomDocument();
  $input->loadXML(trim($tei_string));
  $xsl = $proc->importStylesheet($xsl);
  $newdom = $proc->transformToDoc($input);
  $rdf_xml = $newdom->saveXML();
  drupal_set_message("Converted text");
  drupal_set_message($rdf_xml);
  return $rdf_xml;
}