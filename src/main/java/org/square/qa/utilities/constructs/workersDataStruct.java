package org.square.qa.utilities.constructs;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

public class workersDataStruct<TypeQ,TypeR> {
	private Map<TypeQ,List<TypeR> > responses;
	public workersDataStruct(){
		responses = new HashMap<TypeQ, List<TypeR> >();}
	
	/**
	 * Insert worker responses for each question
	 * @param question is of TypeQ taken by value 
	 * @param response is of TypeR taken by value
	 */
	public void insertWorkerResponse(TypeQ question,TypeR response){
		if(responses.containsKey(question)){
			List<TypeR> current = responses.get(question);
			current.add(response);
			responses.put(question,current);
		}
		else{
			List<TypeR> current = new ArrayList<TypeR>();
			current.add(response);
			responses.put(question, current);
		}
	}
	
	/**
	 * Returns contained worker responses 
	 * @return is a Map of question to list of responses 
	 */
	public Map<TypeQ,List<TypeR> > getWorkerResponses(){
		assert responses!=null:"Attemped to retrieve responses from null object";
		return responses;}
	
	/**
	 * Prints contained responses 
	 */
	public void printWorkerResponses(){
		assert responses!=null:"Attemped to retrieve responses from null object";
		for(TypeQ key:responses.keySet()){
			List<TypeR> repeatResponse = responses.get(key);
			String repeats = " Responses:";
			for(TypeR keyInner:repeatResponse){
				repeats = repeats +"  "+keyInner;}
			System.out.println("\t\tQuestion: "+key+repeats);}}}
