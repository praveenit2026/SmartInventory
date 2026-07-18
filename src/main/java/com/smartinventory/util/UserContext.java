package com.smartinventory.util;

public class UserContext {
    private static final ThreadLocal<String> userRole = new ThreadLocal<>();
    private static final ThreadLocal<Boolean> useDemoData = ThreadLocal.withInitial(() -> false);

    public static void setRole(String role) {
        userRole.set(role);
    }

    public static String getRole() {
        return userRole.get();
    }

    public static void setUseDemoData(boolean value) {
        useDemoData.set(value);
    }

    public static boolean isDemo() {
        return "DEMO".equals(userRole.get()) || useDemoData.get();
    }

    public static void clear() {
        userRole.remove();
        useDemoData.remove();
    }
}
