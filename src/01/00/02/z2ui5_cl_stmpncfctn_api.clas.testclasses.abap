CLASS ltcl_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_func_get_uuid_32 FOR TESTING RAISING cx_static_check.
    METHODS test_func_get_uuid_22 FOR TESTING RAISING cx_static_check.
    METHODS test_encoding         FOR TESTING RAISING cx_static_check.
    METHODS test_element_text     FOR TESTING RAISING cx_static_check.
    METHODS test_classes_impl_intf  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_func_get_uuid_32.

    DATA lv_uuid TYPE string.
    lv_uuid = z2ui5_cl_stmpncfctn_api=>uuid_get_c32( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals(
        act = 32
        exp = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_func_get_uuid_22.

    DATA lv_uuid TYPE string.
    lv_uuid = z2ui5_cl_stmpncfctn_api=>uuid_get_c22( ).
    cl_abap_unit_assert=>assert_not_initial( lv_uuid ).
    cl_abap_unit_assert=>assert_equals(
        act = 22
        exp = strlen( lv_uuid ) ).

  ENDMETHOD.

  METHOD test_encoding.

    DATA lv_string TYPE string.
    DATA lv_xstring TYPE xstring.
    DATA lv_string2 TYPE string.
    DATA lv_xstring2 TYPE xstring.
    DATA lv_string3 TYPE string.
    lv_string   = `my string`.
    
    lv_xstring  = z2ui5_cl_stmpncfctn_api=>conv_get_xstring_by_string( lv_string ).
    
    lv_string2  = z2ui5_cl_stmpncfctn_api=>conv_encode_x_base64( lv_xstring ).
    
    lv_xstring2 = z2ui5_cl_stmpncfctn_api=>conv_decode_x_base64( lv_string2 ).
    
    lv_string3  = z2ui5_cl_stmpncfctn_api=>conv_get_string_by_xstring( lv_xstring2 ).

    cl_abap_unit_assert=>assert_equals(
        act = lv_string3
        exp = lv_string ).

  ENDMETHOD.

  METHOD test_element_text.
    DATA ls_result TYPE z2ui5_cl_stmpncfctn_api=>ty_data_element_texts.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    
    ls_result = z2ui5_cl_stmpncfctn_api=>rtti_get_data_element_texts( `UNAME` ).
    cl_abap_unit_assert=>assert_not_initial( ls_result ).

  ENDMETHOD.

  METHOD test_classes_impl_intf.
    DATA mt_classes TYPE z2ui5_cl_stmpncfctn_api=>tt_classes.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    
    mt_classes = z2ui5_cl_stmpncfctn_api=>rtti_get_classes_impl_intf( `IF_SERIALIZABLE_OBJECT`  ).
    cl_abap_unit_assert=>assert_not_initial( mt_classes ).

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_rfc_bapi_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_rfc_bapi_test IMPLEMENTATION.

  METHOD first_test.

    DATA lo_rfc TYPE REF TO lcl_rfc_bapi.
    lo_rfc = lcl_rfc_bapi=>factory_rfc_destination( `NONE` ).

*    lo_rfc->bapi_message_getdetail(
*      EXPORTING
*        id         = 'LTVF_EXEC'
*        number     = '014'
**        textformat = ''
*      IMPORTING
*        message    = DATA(lv_message)
*    ).

  ENDMETHOD.

ENDCLASS.
