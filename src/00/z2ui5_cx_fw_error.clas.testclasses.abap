CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    METHODS test_raise FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_raise.
        DATA lx TYPE REF TO z2ui5_cx_fw_error.

    TRY.

        RAISE EXCEPTION TYPE z2ui5_cx_fw_error
          EXPORTING
            val = `this is an error text`.

        
      CATCH z2ui5_cx_fw_error INTO lx.
        cl_abap_unit_assert=>assert_equals(
            act                  = lx->get_text( )
            exp                  = `this is an error text` ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
