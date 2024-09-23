

// Сортировка выбором. Разделяет массив на отсортированный и не отсортированный.

class SelectionSort {

        public static void selectionSort(int[] array) {

        for (int i = 0; i < array.length; i++) {
            
            int position = i;
            int min = array[i];
            
            for (int j = i + 1; j < array.length; j++) {
                
                if (array[j] < min) {
                    
                    position = j;
                    min = array[j];
                    
                }
            }
            
            array[position] = array[i];
            array[i] = min;
        }
    }
    
    public static void main (String[] args) {
        
        int[] arr = new int[]{2,7,1,3,2};
        
        selectionSort(arr);
        
        System.out.println(Arrays.toString(arr));       
    }
}
