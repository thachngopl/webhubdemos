package advpackage;

// useful              http://www.guru99.com/introduction-to-selenium-grid.html
// useful              http://marakana.com/bookshelf/selenium_tutorial/selenium2.html#_api
// very useful         http://code.google.com/p/selenium/wiki/GettingStarted
// essential reference http://code.google.com/p/selenium/wiki/Grid2
// nice test example using WordPress target  http://testng.org/doc/selenium.html
// Java "testng" docs  http://testng.org/doc/documentation-main.html
// well written        http://www.packtpub.com/sites/default/files/downloads/Distributed_Testing_with_Selenium_Grid.pdf


//import org.testng.annotations.Test;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.lang.annotation.Annotation;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.*;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;

import org.testng.Assert;
import org.testng.IAnnotationTransformer;
import org.testng.ITest;
import org.testng.TestNG;
import org.testng.annotations.*;
import org.testng.xml.XmlClass;
import org.testng.xml.XmlSuite;
import org.testng.xml.XmlTest;


public class TestADVPages {
	public String baseUrl, selenHub; 
	public DesiredCapabilities capability;
	public String gridURL;
	public String vmr;
	public String threadRemoteIP;
	public String threadUserAgent;
	
	
@Parameters({ "specialZombieCount", "inAuthority", "inSelenHub", "inVMR" })
@BeforeSuite
public void beforeSuite(
		  @Optional("1") String specialZombieCount, 
		  @Optional("lite.demos.href.com") String inAuthority ,  // default "lite.demos.href.com" 
		  @Optional("db.demos.href.com:4444") String inSelenHub,
		  @Optional("") String inVMR) { // scripts/runisa.dll
	
	
	  System.out.println("Suite Parameters follow...");
	  System.out.println("inAuthority = " +  inAuthority);
	  System.out.println("inSelenHub = " + inSelenHub);
	  System.out.println("inVMR = " + inVMR);
	  vmr = inVMR;
	  
	  System.out.println("Calculated testing values follow...");

    baseUrl = "http://" + inAuthority; 
    System.out.println("baseUrl = " + baseUrl);

	//selenHub = "db.demos.href.com:4444"; 
	selenHub = "localhost:4444";
	//selenHub = inSelenHub;
		  
	gridURL = "http://" + selenHub + "/wd/hub";
	System.out.println("gridURL = " + gridURL);
	
}
	  

@BeforeTest
  public void setUp() throws MalformedURLException {
		
	capability = DesiredCapabilities.htmlUnit();   
	// as htmlUnit, the user agent goes through as Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0) 
	  
	capability.setBrowserName(DesiredCapabilities.htmlUnit().getBrowserName());	  
	//capability.setPlatform(org.openqa.selenium.Platform.WINDOWS);	  
    capability.setPlatform(org.openqa.selenium.Platform.ANY);	  
  }
	
  @AfterTest
  public void afterTest() {
  }
  	

  @Test(timeOut = 45000, enabled = true)
  public void verifyMyIP() throws MalformedURLException {
	  
	  if ("".equals(vmr)) {
	  }
	  else {
		  System.out.println("test vmr = " + vmr);
		WebDriver driver; 
	
		WebElement webElement;
		
		driver = new RemoteWebDriver(new URL(gridURL), capability);
		driver.manage().deleteAllCookies();

	    driver.get(baseUrl + "/" + vmr + "?demos:pgwhatismyip");
	    webElement = (driver.findElement(By.id("ip")));
	    threadRemoteIP = webElement.getText();
	    System.out.println("remoteAddress = " + threadRemoteIP);
	    webElement = (driver.findElement(By.id("ua")));
	    threadUserAgent = webElement.getText(); 
	    	    
	    //System.out.println("userAgent = " + webElement.getText());
	    
     driver.quit();
	  }
	  }


  @Test(timeOut = 45000, enabled = false)
  public void verifyADVWalkthrough() throws MalformedURLException {
	  
	  if ("".equals(vmr)) {
	  }
	  else {
	  
	WebDriver driver; 
	
	driver = new RemoteWebDriver(new URL(gridURL), capability);
	driver.manage().deleteAllCookies();
	
    driver.get(baseUrl + "/" + vmr + "?adv");
	  
	//System.out.println("03");
	String expectedTitle = "Page pgWelcome: Welcome Page for adv Demo (in the \"adv\" WebHub Demo)";
	String actualTitle = driver.getTitle();
	System.out.println(actualTitle);
	  
	Assert.assertEquals(actualTitle, expectedTitle);
	  
     driver.findElement(By.id("a-pgenteradv")).click();
     
     driver.findElement(By.linkText("Internal Workings")).click();
     driver.findElement(By.linkText("Cycle List Navigation Bar")).click();
     driver.findElement(By.linkText("How to Use it")).click();
     driver.findElement(By.cssSelector("img[alt=\"Logo for adv WebHub demo\"]")).click();
     driver.findElement(By.id("a-viewfiles")).click();
     driver.findElement(By.cssSelector("img[alt=\"Logo for adv WebHub demo\"]")).click();
     driver.findElement(By.id("a-pgabout")).click();
     driver.findElement(By.cssSelector("img[alt=\"Logo for adv WebHub demo\"]")).click();
     driver.findElement(By.id("a-pgenteradv")).click();
     driver.findElement(By.linkText("Click to Show Next Advertisement")).click();
     driver.findElement(By.linkText("Click to Show Next Advertisement")).click();
     driver.findElement(By.linkText("Click to Show Next Advertisement")).click();
     driver.findElement(By.linkText("Click to Show Next Advertisement")).click();
     driver.findElement(By.linkText("Click to Show Next Advertisement")).click();
     

     driver.quit();
	} 
  }

  
  @Test(timeOut = 45000, enabled = true)
  public void verifyDemosWalkThrough() throws MalformedURLException {
	  
	  if ("".equals(vmr)) {
	  }
	  else {
		  
		  WebDriver driver;
	  
	String actualTitle;
	String expectedTitle;
	
	driver = new RemoteWebDriver(new URL(gridURL), capability);
	driver.manage().deleteAllCookies();

   	    driver.get(baseUrl + "/" + vmr + "?demos");
   	    actualTitle = driver.getTitle();
   	    System.out.println(actualTitle);
     	  expectedTitle = "Page pgWelcome: Welcome Page for demos Demo (in the \"demos\" WebHub Demo)";
	    Assert.assertEquals(actualTitle, expectedTitle);
   	    driver.findElement(By.id("a-pgenterdemos")).click();
  	    driver.findElement(By.linkText("Lite Demos")).click();
  	    driver.findElement(By.linkText("Source")).click();
     
     driver.quit();
	  }   
  }

  
  @Test(timeOut = 45000, enabled = false)
  public void verifyDemosStressFrame() throws MalformedURLException {
	  if ("".equals(vmr)) {
		  
		  WebDriver driver;

	String actualTitle;
	String expectedTitle;
	
	driver = new RemoteWebDriver(new URL(gridURL), capability);
	driver.manage().deleteAllCookies();

   	    driver.get(baseUrl + "/" + vmr + "?demos");
   	    actualTitle = driver.getTitle();
   	    System.out.println(actualTitle);
     	  expectedTitle = "Page pgWelcome: Welcome Page for demos Demo (in the \"demos\" WebHub Demo)";
	    Assert.assertEquals(actualTitle, expectedTitle);
   	    driver.findElement(By.id("a-pgenterdemos")).click();
  	    driver.findElement(By.linkText("Lite Demos")).click();
  	    driver.findElement(By.linkText("Source")).click();
     
     driver.quit();
	  }  
  }

  	  
 // when running As Application, this must use the static main method contained in the testng jar !!!
  
}
