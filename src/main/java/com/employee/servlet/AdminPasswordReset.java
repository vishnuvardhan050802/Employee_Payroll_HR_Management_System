package com.employee.servlet;

import com.employee.config.DatabaseConnection;
import com.employee.util.PasswordUtil;
import java.io.Console;
import java.sql.Connection;
import java.sql.PreparedStatement;

/** Safely resets an existing active administrator password from a local terminal. */
public final class AdminPasswordReset {
    private AdminPasswordReset() { }
    public static void main(String[] args) throws Exception {
        Console console = System.console();
        if (console == null) throw new IllegalStateException("Run this in Windows Terminal or the VS Code terminal, not the Output panel.");
        String username = console.readLine("Administrator username to reset: ");
        char[] first = console.readPassword("New password (12+ characters): ");
        if (first.length < 12) throw new IllegalArgumentException("Use at least 12 characters.");
        char[] again = console.readPassword("Confirm new password: ");
        if (!java.util.Arrays.equals(first, again)) throw new IllegalArgumentException("Passwords did not match.");
        String password = new String(first);
        java.util.Arrays.fill(first, '\0');
        java.util.Arrays.fill(again, '\0');
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "UPDATE users SET password_hash=? WHERE username=? AND role='ADMIN' AND active=TRUE")) {
            statement.setString(1, PasswordUtil.hash(password));
            statement.setString(2, username);
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("No active administrator with that username was found.");
            System.out.println("Administrator password updated.");
        }
    }
}
