public class ValueCounter{
    
    public static Map<String, Integer> countOccurences(List<String> inputList){  
        Map<String,Integer> countValue = new Map<String,Integer>();
        
        if(inputList == null)
        {
            return countValue;
        }
        
        for( String str:inputList)
        {
            if (countValue.containsKey(str)) {
                countValue.put(str, countValue.get(str) + 1);
            }else{
               countValue.put(str, 1);
            }
        }
            
            Return countValue;
            
      
    }
  }