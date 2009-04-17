
package edu.lter.projectdb.ws;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.RequestWrapper;
import javax.xml.ws.ResponseWrapper;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.4-b01-
 * Generated source version: 2.1
 * 
 */
@WebService(name = "LTERproject", targetNamespace = "http://ws.projectDB.lter.edu/")
@XmlSeeAlso({
    ObjectFactory.class
})
public interface LTERproject {


    /**
     * 
     * @param projectId
     * @return
     *     returns java.lang.String
     */
    @WebMethod
    @WebResult(targetNamespace = "")
    @RequestWrapper(localName = "getProjectById", targetNamespace = "http://ws.projectDB.lter.edu/", className = "edu.lter.projectdb.ws.GetProjectById")
    @ResponseWrapper(localName = "getProjectByIdResponse", targetNamespace = "http://ws.projectDB.lter.edu/", className = "edu.lter.projectdb.ws.GetProjectByIdResponse")
    public String getProjectById(
        @WebParam(name = "projectId", targetNamespace = "")
        String projectId);

}
