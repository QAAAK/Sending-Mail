import java.util.*;
import java.lang.*;
import java.io.*;
import java.util.Arrays;

class InsertingSort
  
{
	public static void insertingSort (int[] array)
	
	{   
	    int j;
	    
		for (int i =0 ; i < array.length; i++) {
		    
		   int swap = array[i];
		   
		   for (j = i; j > 0 && swap < array[j - 1]; j--) {
		       
		       array[j] = array[j - 1];
		       
		   }
		    
		  array[j] = swap;
		}
		            
		      
		

	}
	
	
	public static void main (String[] args) {
	    
	    
	    int[] arr = new int[]{1,3,5,1};
	    
	    insertingSort(arr);
	    
	    System.out.println(Arrays.toString(arr));
	    
	    
	}
}
