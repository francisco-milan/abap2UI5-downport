CLASS z2ui5_cl_core_app_info DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_check_initialized TYPE abap_bool.

    DATA mv_ui5_version TYPE string.
*    DATA mv_device TYPE string.
*    DATA mv_device_type TYPE string.
*    DATA mv_theme TYPE string.
*    DATA mv_device_browser TYPE string.
*    DATA mv_device_theme TYPE string.
*    DATA mv_device_gav TYPE string.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_core_app_info.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_start.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_core_app_info IMPLEMENTATION.


  METHOD factory.

    CREATE OBJECT result.

  ENDMETHOD.


  METHOD view_display_start.

    DATA page2 TYPE REF TO z2ui5_cl_xml_view.
    DATA simple_form2 TYPE REF TO z2ui5_cl_xml_view.
    DATA temp1 TYPE string.
    DATA temp2 TYPE REF TO z2ui5_cl_core_draft_srv.
    DATA lv_count LIKE temp1.
    page2 = z2ui5_cl_xml_view=>factory( )->shell( )->page(
         shownavbutton = abap_false ).

    page2->header_content( )->text(  )->title( `abap2UI5 - System Information` )->toolbar_spacer( ).

    page2->_z2ui5( )->info_frontend(
*        device_browser = client->_bind( mv_device_browser )
*        device_systemtype = client->_bind( mv_device_type )
*        ui5_gav = client->_bind( mv_device_gav )
*        ui5_theme = client->_bind( mv_device_theme )
        ui5_version = client->_bind( mv_ui5_version ) ).

    
    simple_form2 = page2->simple_form(
        editable                = abap_true
        layout                  = `ResponsiveGridLayout`
        labelspanxl             = `4`
        labelspanl              = `3`
        labelspanm              = `4`
        labelspans              = `12`
        adjustlabelspan         = abap_false
        emptyspanxl             = `0`
        emptyspanl              = `4`
        emptyspanm              = `0`
        emptyspans              = `0`
        columnsxl               = `1`
        columnsl                = `1`
        columnsm                = `1`
        singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form2->toolbar( )->title( `Frontend` ).

    simple_form2->label( `UI5 Version`).
    simple_form2->text( client->_bind( mv_ui5_version ) ).
    simple_form2->label( `Launchpad active` ).
    simple_form2->checkbox( enabled = abap_false selected = client->get( )-check_launchpad_active ).
* simple_form2->label( `Browser` ).
*  simple_form2->text( client->_bind( mv_device_browser ) ).
* simple_form2->label( `Bootstrap` ).
*   simple_form2->text( client->_bind( mv_device_gav ) ).
* simple_form2->label( `Theme` ).
*   simple_form2->text( client->_bind( mv_device_theme ) ).
*   simple_form2->label( `Type` ).
*   simple_form2->text( client->_bind( mv_device_type ) ).

    simple_form2->toolbar( )->title( `Backend` ).

    simple_form2->label( `ABAP for Cloud` ).
    simple_form2->checkbox( enabled = abap_false selected = z2ui5_cl_util=>rtti_check_lang_version_cloud( ) ).

    
    
    CREATE OBJECT temp2 TYPE z2ui5_cl_core_draft_srv.
    temp1 = temp2->count( ).
    
    lv_count = temp1.
    simple_form2->toolbar( )->title( `abap2UI5` ).
    simple_form2->label( `Version ` ).
    simple_form2->text( z2ui5_if_app=>version ).
    simple_form2->label( `Draft Entries ` ).
    simple_form2->text( lv_count ).

    client->view_display( page2->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      z2ui5_on_init( ).
      view_display_start( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      view_display_start( ).
      RETURN.
    ENDIF.

    z2ui5_on_event( ).
    view_display_start( ).

  ENDMETHOD.


  METHOD z2ui5_on_event.


  ENDMETHOD.


  METHOD z2ui5_on_init.

  ENDMETHOD.

ENDCLASS.
