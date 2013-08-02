package footprints.client;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.rpc.ServiceDefTarget;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.RootPanel;
import footprints.client.data_type.code_metrics.JsoCollectionDTO;
import footprints.client.service.code_metrics.JavaNcssRestService;
import footprints.shared.service.code_metrics.GwtJavaNcss;
import footprints.shared.service.code_metrics.GwtJavaNcssAsync;
import java.util.List;
import org.fusesource.restygwt.client.Method;
import org.fusesource.restygwt.client.OverlayCallback;
import org.fusesource.restygwt.client.Resource;
import org.fusesource.restygwt.client.RestServiceProxy;

public final class Footprints
  implements EntryPoint
{
  public void onModuleLoad()
  {
    final Button button = new Button( "Place Pizza Order" );
    button.addClickHandler( new ClickHandler()
    {
      public void onClick( ClickEvent event )
      {
        JavaNcssRestService service = GWT.create( JavaNcssRestService.class );
        Resource resource = new Resource( GWT.getHostPageBaseURL() + "api" + JavaNcssRestService.PATH );
        ( (RestServiceProxy) service ).setResource( resource );
        service.getCollections( new OverlayCallback<JsArray<JsoCollectionDTO>>()
        {
          @Override
          public void onFailure( final Method method, final Throwable exception )
          {
            Window.alert( "Failed - REST" );
          }

          @Override
          public void onSuccess( final Method method, final JsArray<JsoCollectionDTO> response )
          {
            Window.alert( "Success - REST" );
          }
        } );
        Window.alert( "Order Placed via Rest" );

        final GwtJavaNcssAsync service2 = GWT.create( GwtJavaNcss.class );
        service2.getCollections( new AsyncCallback<List<String>>()
        {
          @Override
          public void onFailure( final Throwable caught )
          {
            Window.alert( "Failed - RPC" );
          }

          @Override
          public void onSuccess( final List<String> result )
          {
            Window.alert( "Success - RPC" );
          }
        } );
        Window.alert( "Order Placed via RPC" );
      }

    } );
    RootPanel.get().add( button );
  }
}
