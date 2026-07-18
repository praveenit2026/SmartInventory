package com.smartinventory.util;

public class UserContext {
    private static final ThreadLocal<String> userRole = new ThreadLocal<>();

    public static void setRole(String role) {
        userRole.set(role);
    }

    public static String getRole() {
        return userRole.get();
    }

    public static boolean isDemo() {
        return "DEMO".equals(userRole.get());
    }

    public static void clear() {
        userRole.remove();
    }
}
