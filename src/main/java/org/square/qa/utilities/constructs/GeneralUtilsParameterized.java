package org.square.qa.utilities.constructs;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;

import org.apache.log4j.Logger;
import org.jblas.DoubleMatrix;

public class GeneralUtilsParameterized<TypeWID,TypeQ,TypeR> {
	private static Logger log = Logger.getLogger(GeneralUtilsParameterized.class);
	public GeneralUtilsParameterized() {}
	
	/**
	 * Extract questions from workers map
	 * @param workersMap is a Map from worker ids to an object holding question and responses
	 * @return a Set holding all questions
	 */
	public Set<TypeQ> getQuestions(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap){
		SortedSet<TypeQ> questions = new TreeSet<TypeQ>();
		for(TypeWID key:workersMap.keySet()){
			questions.addAll(workersMap.get(key).getWorkerResponses().keySet());}
		return questions;}
	
	/**
	 * Extract questions from ground truth
	 * @param gt is Map from questions to responses
	 * @return a Set holding questions
	 */
	public Set<TypeQ> getQuestionsGT(Map<TypeQ,TypeR> gt){
		SortedSet<TypeQ> questions = new TreeSet<TypeQ>();
		questions.addAll(gt.keySet());
		return questions;}
	
	/**
	 * Filter worker responses to include input questions only
	 * @param workersMap is a Map from workers to an object holding questions and responses
	 * @param questions is a List of questions
	 * @return filtered workersMap
	 */
	public Map<TypeWID,workersDataStruct<TypeQ,TypeR> > getFilteredWorkerMap(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap, List<TypeQ> questions){
		Map<TypeWID,workersDataStruct<TypeQ,TypeR> > filteredWMap = new HashMap<TypeWID, workersDataStruct<TypeQ,TypeR> >();
		for(TypeWID key:workersMap.keySet()){
			workersDataStruct<TypeQ, TypeR> tempStruct = new workersDataStruct<TypeQ, TypeR>();
			boolean contributed = false;
			for(TypeQ keyInner:workersMap.get(key).getWorkerResponses().keySet()){
				if(questions.contains(keyInner)){
					contributed = true;
					List<TypeR> rList = workersMap.get(key).getWorkerResponses().get(keyInner);
					for(TypeR resp:rList){
						tempStruct.insertWorkerResponse(keyInner, resp);}}}
			
			if(contributed)
				filteredWMap.put(key, tempStruct);}
		return filteredWMap;}
	
	/**
	 * Filter ground truth to include input questions only
	 * @param gt is a Map from questions to responses 
	 * @param questions is a List of questions
	 * @return is a Map from questions to responses
	 */
	public Map<TypeQ,TypeR> getFilteredGT(Map<TypeQ,TypeR> gt, List<TypeQ> questions){
		Map<TypeQ,TypeR> filteredMap = new HashMap<TypeQ,TypeR>();
		for(TypeQ question:questions){
			if(gt.containsKey(question)){
				filteredMap.put(question, gt.get(question));}}
		return filteredMap;}
	
	/**
	 * Compute a map from questions to integers
	 * @param workersMap is a Map from workers to an object holding questions and responses
	 * @return a Map from Questions to Integers
	 */
	public Map<TypeQ,Integer> getQuestionIntMap(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap){
		SortedSet<TypeQ> questions = new TreeSet<TypeQ>();
		questions.addAll(this.getQuestions(workersMap));
		Map<TypeQ,Integer> questionIntMap = new HashMap<TypeQ, Integer>();
		int i = 1;
		for(TypeQ key:questions){
			questionIntMap.put(key, i);
			i++;}
		return questionIntMap;}
	
	/**
	 * Compute a map from workers to integers
	 * @param workersMap is a Map from workers to an object holding questions and responses
	 * @return a Map from Workers to Integers
	 */
	public Map<TypeWID,Integer> getWorkerIntMap(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap){
		Map<TypeWID,Integer> workerIntMap = new HashMap<TypeWID, Integer>();
		int i = 1;
		for(TypeWID key:workersMap.keySet()){
			workerIntMap.put(key, i);
			i++;}
		return workerIntMap;}
	
	/**
	 * Print worker responses to file -- categToInt, workerToInt and questionToInt need to be valid
	 * @param workersMap is a Map from workers to an object holding questions and responses
	 * @param file is of type File -- output file
	 * @throws FileNotFoundException
	 */
	public void printNumberedResponses(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap, File file) throws FileNotFoundException{
		log.assertLog(GeneralUtils.nFoldSet.categToInt != null && GeneralUtils.nFoldSet.workerToInt != null && GeneralUtils.nFoldSet.questionToInt != null, "Category to Integer Maps Not Defined");
		assert GeneralUtils.nFoldSet.categToInt != null && GeneralUtils.nFoldSet.workerToInt != null && GeneralUtils.nFoldSet.questionToInt != null:"Category to Integer Maps Not Defined";
		
		PrintWriter out = new PrintWriter(file);
		boolean first = true;
		for(TypeWID key:workersMap.keySet()){
			workersDataStruct<TypeQ, TypeR> currentWorker = workersMap.get(key);
			Map<TypeQ,List<TypeR> > currentWorkerResponses = currentWorker.getWorkerResponses();
			for(TypeQ question:currentWorkerResponses.keySet()){
				List<TypeR> responses = currentWorkerResponses.get(question);
				for(TypeR response:responses){
					String outString = GeneralUtils.nFoldSet.questionToInt.get(question) + " " + GeneralUtils.nFoldSet.workerToInt.get(key) + " " + GeneralUtils.nFoldSet.categToInt.get(response);
					if(!first)
						out.print("\n");
					out.print(outString);
					first = false;
					if(log.isDebugEnabled()){
						log.debug(outString);}}}}
		out.close();}
	
	/**
	 * Print ground truth to file -- categToInt, workerToInt and questionToInt need to be valid
	 * @param gt is a Map from questions to responses
	 * @param file is of type File -- output file
	 * @throws FileNotFoundException
	 */
	public void printNumberedGT(Map<TypeQ,TypeR> gt, File file) throws FileNotFoundException{
		log.assertLog(GeneralUtils.nFoldSet.categToInt != null && GeneralUtils.nFoldSet.questionToInt != null, "Category to Integer Map Not Defined");
		assert GeneralUtils.nFoldSet.categToInt != null && GeneralUtils.nFoldSet.questionToInt != null:"Category to Integer Map Not Defined";
		PrintWriter out = new PrintWriter(file);
		boolean first = true;
		for(TypeQ key:gt.keySet()){
			String outString = GeneralUtils.nFoldSet.questionToInt.get(key) + " " + GeneralUtils.nFoldSet.categToInt.get((gt.get(key)));
			if(!first)
				out.print("\n");
			out.print(outString);
			first = false;
			if(log.isDebugEnabled()){
				log.debug(outString);}}
		out.close();}
	
	/**
	 * Map response categories to integers
	 * @param responseCategories is a Set of type responses holding response categories	
	 * @return a Map from response categories to integers
	 */
	public Map<TypeR,Integer> getCategIntMap(Set<TypeR> responseCategories){
		Map<TypeR,Integer> categToInt = new HashMap<TypeR, Integer>();
		int temp = 1;
		for(TypeR iter:responseCategories){
			categToInt.put(iter,temp);
			temp++;}
		return categToInt;}
	
	/**
	 * Print responses mapped to integers to a file
	 * @param responseToInt is a Map from response categories to integers
	 * @param file is a File -- output file
	 * @throws FileNotFoundException
	 */
	public void printMapFileRI(Map<TypeR,Integer> responseToInt, File file) throws FileNotFoundException{
		log.assertLog(GeneralUtils.nFoldSet.categToInt != null, "Category to Integer Map Not Defined");
		assert GeneralUtils.nFoldSet.categToInt != null:"Category to Integer Map Not Defined";
		PrintWriter out = new PrintWriter(file);
		boolean first = true;
		for(TypeR response:responseToInt.keySet()){
			if(!first)
				out.print("\n");
			String outString = response + " " + responseToInt.get(response);
			out.print(outString);
			first = false;
			if(log.isDebugEnabled()){
				log.debug(outString);}}
		out.close();}
	
	/**
	 * Print questions mapped to integers to a file
	 * @param questionToInt is a Map from questions to integers
	 * @param file is File -- output file
	 * @throws FileNotFoundException
	 */
	public void printMapFileQI(Map<TypeQ,Integer> questionToInt, File file) throws FileNotFoundException{
		log.assertLog(GeneralUtils.nFoldSet.questionToInt != null, "Question to Integer Map Not Defined");
		assert GeneralUtils.nFoldSet.questionToInt != null:"Question to Integer Map Not Defined";
		PrintWriter out = new PrintWriter(file);
		boolean first = true;
		for(TypeQ question:questionToInt.keySet()){
			if(!first)
				out.print("\n");
			String outString = question + " " + questionToInt.get(question);
			out.print(outString);
			first = false;
			if(log.isDebugEnabled()){
				log.debug(outString);}}
		out.close();}
	
	/**
	 * Print workers mapped to integers to a file
	 * @param workerToInt is a Map from workers to integers
	 * @param file is a File -- output file
	 * @throws FileNotFoundException
	 */
	public void printMapFileWI(Map<TypeWID,Integer> workerToInt,File file) throws FileNotFoundException{
		log.assertLog(GeneralUtils.nFoldSet.workerToInt != null, "Worker to Integer Map Not Defined");
		assert GeneralUtils.nFoldSet.workerToInt != null:"Worker to Integer Map Not Defined";
		PrintWriter out = new PrintWriter(file);
		boolean first = true;
		for(TypeWID worker:workerToInt.keySet()){
			if(!first)
				out.print("\n");
			String outString = worker + " " + workerToInt.get(worker);
			out.print(outString);
			first = false;
			if(log.isDebugEnabled()){
				log.debug(outString);}}
		out.close();}
	
	/**
	 * Prints workerStatistics.txt dataStatistics.txt and questionStatistics.txt
	 * @param workersMap is a Map from workers to an object holding questions and responses
	 * @param outDir of type File is the output directory to print files
	 * @throws FileNotFoundException
	 */
	public void printStatistics(Map<TypeWID,workersDataStruct<TypeQ,TypeR> > workersMap, File... outDir) throws FileNotFoundException{
		log.assertLog(outDir.length<2, "Only one output directory path accepted");
		assert outDir.length<2:"Only one output directory path accepted";
		log.info("Computing worker statistics");
		DoubleMatrix questionCounts = DoubleMatrix.zeros(workersMap.size());
		DoubleMatrix responseCounts = DoubleMatrix.zeros(workersMap.size());
		Map<TypeWID,Integer> workerIdx = new HashMap<TypeWID, Integer>();
		Map<TypeQ,Integer> workersPerQuestion = new HashMap<TypeQ, Integer>();
		int i = 0;
		for(TypeWID key:workersMap.keySet()){
			workerIdx.put(key, i);
			workersDataStruct<TypeQ, TypeR> currentWorker = workersMap.get(key);
			if(log.isDebugEnabled()){
				log.debug("Printing Worker Responses for: "+key);
				currentWorker.printWorkerResponses();}
			
			Map<TypeQ,List<TypeR> > currentWorkerResponses = currentWorker.getWorkerResponses();
			int questionCount = 0;
			int responseCount = 0;
			
			for(TypeQ question:currentWorkerResponses.keySet()){
				questionCount++;
				if(workersPerQuestion.containsKey(question))
					workersPerQuestion.put(question, workersPerQuestion.get(question) + 1);
				else
					workersPerQuestion.put(question, 0);
					
				List<TypeR> responses = currentWorkerResponses.get(question);
				for(TypeR response:responses){
					responseCount++;
					if(log.isDebugEnabled()){
						log.debug(GeneralUtils.nFoldSet.workerToInt.get(key) + " " + GeneralUtils.nFoldSet.questionToInt.get(question) + " " + GeneralUtils.nFoldSet.categToInt.get(response));}}
				questionCounts.put(i, questionCount);
				responseCounts.put(i, (double)responseCount/(double)questionCount);}
			i++;}
		if(log.isDebugEnabled()){
			log.debug(workerIdx);
			log.debug(questionCounts);
			log.debug(responseCounts);}
		DoubleMatrix questionCountsSorted = questionCounts.sort();
		DoubleMatrix questionCountsZeroMean = questionCounts.add(-1.0d*questionCounts.mean());
		int numQuestions = getQuestions(workersMap).size();
		int numResponses = (int)questionCounts.sum();
		int numWorkers = questionCounts.length;
		double avgQPW = questionCounts.mean();
		double stdQPW = Math.sqrt(questionCountsZeroMean.dot(questionCountsZeroMean)/(double)(questionCounts.length - 1.0d));
		double medQPR = questionCountsSorted.get((int)Math.floor(questionCounts.length/2));
		int minAnswered = (int)questionCountsSorted.get(0);
		int maxAnswered = (int)questionCountsSorted.get(questionCounts.length-1);
		double avgRPW = responseCounts.mean();
		log.info("Number of Questions: " + numQuestions);
		log.info("Number of Responses: " + numResponses);
		log.info("Number of Wokers: " + numWorkers);
		log.info("Average number of questions answered per worker: " + avgQPW);
		log.info("Standard Deviation: " + stdQPW);
		log.info("Median of questions answered per worker: " + medQPR);
		log.info("Minimun number of questions answered by a worker: " + minAnswered);
		log.info("Maximum number of questions answered by a worker: " + maxAnswered);
		log.info("Average number of responses by each worker: " + avgRPW);
		
		//write to files
		if(outDir.length == 1){
			String Path;
			if(outDir[0].exists()){
				Path = outDir[0].getAbsolutePath();
			} else {
				outDir[0].mkdirs();
				Path = outDir[0].getAbsolutePath();}
			PrintWriter out = new PrintWriter(new File(Path+"/worker_Statistics.txt"));
			for(TypeWID worker:workerIdx.keySet()){
				out.println(workerIdx.get(worker)+ "\t" + questionCounts.get(workerIdx.get(worker)));}
			out.close();
			
			out = new PrintWriter(new File(Path+"/question_Statistics.txt"));
			int questionInt = 1;
			double avgCount = 0;
			for(TypeQ question:workersPerQuestion.keySet()){
				out.println( questionInt + "\t" + workersPerQuestion.get(question));
				avgCount = avgCount + workersPerQuestion.get(question);
				questionInt++;}
			double avgWPQ = avgCount / (double)questionInt;
			log.info("Average number of workers per question: " + avgWPQ);
			out.close();
			
			out = new PrintWriter(new File(Path+"/dataStatistics.txt"));
			out.println("Number of Questions: " + numQuestions);
			out.println("Number of Responses: " + numResponses);
			out.println("Number of Wokers: " + numWorkers);
			out.println("Average number of questions answered per worker: " + avgQPW);
			out.println("Standard Deviation: " + stdQPW);
			out.println("Median of questions answered per worker: " + medQPR);
			out.println("Minimun number of questions answered by a worker: " + minAnswered);
			out.println("Maximum number of questions answered by a worker: " + maxAnswered);
			out.println("Average number of responses by each worker: " + avgRPW);
			out.println("Average number of workers per question: " + avgWPQ);
			out.close();}}
	
	/**
	 * Get question and estimated results from combined results
	 * @param combined is a Map from questions to a Pair holding the most probable result and other result probabilities
	 * @return a Map from questions to estimated results
	 */
	public Map<TypeQ,TypeR> getQuestionResultPair(Map<TypeQ,Pair<TypeR, Map<TypeR,Double> > > combined){
		Map<TypeQ,TypeR> qrPairs = new HashMap<TypeQ,TypeR>();
		for (TypeQ key:combined.keySet()){
			qrPairs.put(key, combined.get(key).getFirst());}
		return qrPairs;}}
