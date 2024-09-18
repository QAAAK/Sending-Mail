import java.util.Arrays;

// Проверяем соседние элементы, если следующий элемент меньше предыдущего, меняем их местами

public class BubbleSort {

    public static void sort (int[] array) {
        for (int i = 0; i < array.length-1; i++) {

            for (int j = 0; j < array.length - i - 1; j++) {

                if (array[j+1] < array[j]) {

                    int swap = array[j];
                    array[j] = array[j + 1];
                    array[j + 1] = swap;

                }
            }
        }
    }

    public static void main (String [] args) {

        int[] arr = new int[]{10,3,8,11,9};

        sort(arr);

        System.out.println(Arrays.toString(arr));

    }
}
