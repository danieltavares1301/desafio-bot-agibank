public with sharing class DateUtils {
    public static Date parseDate(String dmy) {
        if (String.isBlank(dmy)) return null;
        List<String> p = dmy.split('/');
        if (p.size() != 3) return null;
        return Date.newInstance(
            Integer.valueOf(p[2]),
            Integer.valueOf(p[1]),
            Integer.valueOf(p[0])
        );
    }
}