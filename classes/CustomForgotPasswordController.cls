/**
 * An apex page controller that exposes the site forgot password functionality
 */
global with sharing class CustomForgotPasswordController {
    global String username {get; set;}   
       
    global CustomForgotPasswordController() {}
	
  	global PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.CustomCommunitiesConfirmForgotPassword;
  		pr.setRedirect(true);
  		
  		if (success) {  			
  			return pr;
  		}
  		return null;
  	}
    
      
    global PageReference cancel() {
       String startUrl = System.currentPageReference().getParameters().get('startURL');
       return new PageReference( startUrl);
   ///return new PageReference( '/apex/CustomCommunitiesLoginPage');
    }
    
    global PageReference contactUs() {
      //  PageReference forgotPage = new PageReference('/apex/communitiesEstatement#/contact');
        PageReference page = new PageReference('/CustomContactUs#/contact');
    page.setRedirect(false);
    return page;
    } 
    
    
    
}