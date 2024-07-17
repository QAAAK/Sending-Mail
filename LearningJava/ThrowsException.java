public class TrowsException {

    public static void main (String [] args) {

        sumMul(2,9);

    }

    public static long sumMul(int n, int m) {
        if (n < 1 || m < 1) throw new IllegalArgumentException("n or m < 1");
        int x = (m - 1) / n;
        return (long) (n * 0.5 * x * (x + 1));
    }
}
