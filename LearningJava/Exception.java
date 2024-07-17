public class Exception {
    public static void main (String [] args) {

        int[] arr = new int[3];

        try {

            arr[4] = 10;

        }
        catch (Throwable exc) {

            System.out.println("Нельзя добавить элемент в массив");
        }
    }
}
