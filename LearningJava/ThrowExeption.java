public class ThrowExeption {

    public static void main(String[] args) {

        try {

            int[] test = {1, 2, 3};

            int a = test[1];


        } catch (Throwable exc) {

            System.out.println("No");
            throw new ArithmeticException("/ by zero");
        }


    }

}
