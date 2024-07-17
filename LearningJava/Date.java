import java.time.LocalDate;


public class Date {
}

class Cata_1 {


        public static boolean periodIsLate(LocalDate last,LocalDate today,int cycleLength) {

            LocalDate total = last.plusDays(cycleLength);

            if (total.isAfter(today)) {
                return true;
            } else return false;
    }
}