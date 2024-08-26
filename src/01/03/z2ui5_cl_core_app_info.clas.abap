class Z2UI5_CL_CORE_APP_INFO definition
  public
  final
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .
  interfaces Z2UI5_IF_APP .

  data CLIENT type ref to Z2UI5_IF_CLIENT .
  data MV_CHECK_INITIALIZED type ABAP_BOOL .
  data MV_UI5_VERSION type STRING .

*    DATA mv_device TYPE string.
*    DATA mv_device_type TYPE string.
*    DATA mv_theme TYPE string.
*    DATA mv_device_browser TYPE string.
*    DATA mv_device_theme TYPE string.
*    DATA mv_device_gav TYPE string.
  class-methods FACTORY
    returning
      value(RESULT) type ref to Z2UI5_CL_CORE_APP_INFO .
  methods Z2UI5_ON_EVENT .
  methods VIEW_DISPLAY_START .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CORE_APP_INFO IMPLEMENTATION.


  METHOD factory.

    CREATE OBJECT result.

  ENDMETHOD.


  METHOD view_display_start.

    DATA page2 TYPE REF TO z2ui5_cl_xml_view.
    DATA content TYPE REF TO z2ui5_cl_xml_view.
    DATA simple_form2 TYPE REF TO z2ui5_cl_xml_view.
    DATA temp1 TYPE string.
    DATA temp2 TYPE REF TO z2ui5_cl_core_draft_srv.
    DATA lv_count LIKE temp1.
    page2 = z2ui5_cl_xml_view=>factory_popup(
         )->dialog(
*            stretch    = abap_true
            title      = `abap2UI5 - System Information`
            afterclose = client->_event( `CLOSE` ) ).

*    page2->header_content( )->text(  )->title( `abap2UI5 - System Information` )->toolbar_spacer( ).

    
    content = page2->content( ).
    content->_z2ui5( )->info_frontend(
*        device_browser = client->_bind( mv_device_browser )
*        device_systemtype = client->_bind( mv_device_type )
*        ui5_gav = client->_bind( mv_device_gav )
*        ui5_theme = client->_bind( mv_device_theme )
        ui5_version = client->_bind( mv_ui5_version ) ).

    
    simple_form2 = content->simple_form(
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

    simple_form2->label( `UI5 Version` ).
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
    temp1 = temp2->count_entries( ).
    
    lv_count = temp1.
    simple_form2->toolbar( )->title( `abap2UI5` ).
    simple_form2->label( `Version ` ).
    simple_form2->text( z2ui5_if_app=>version ).
    simple_form2->label( `Draft Entries ` ).
    simple_form2->text( lv_count ).

*    page2->
    page2->end_button( )->button(
                      text  = 'close'
                      press = client->_event( 'CLOSE' )
                      type  = 'Emphasized' ).

    client->popup_display( page2->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      view_display_start( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      view_display_start( ).
      RETURN.
    ENDIF.

    z2ui5_on_event( ).

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN `CLOSE`.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
