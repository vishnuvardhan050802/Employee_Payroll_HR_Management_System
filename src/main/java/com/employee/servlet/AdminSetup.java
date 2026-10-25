package com.employee.servlet;

import com.employee.config.DatabaseConnection;
import com.employee.util.PasswordUtil;
import java.io.Console;
import java.sql.Connection;
import java.sql.PreparedStatement;

/** Run once from a terminal to create the first administrator account. */
public final class AdminSetup {
    public static void main(String[] args) throws Exception {
        Console console=System.console(); if(console==null)throw new IllegalStateException("Run this command in Windows Terminal or Command Prompt, not the VS Code output panel.");
        String username=console.readLine("Administrator username: "); char[] first=console.readPassword("New password (12+ characters): ");
        if(first.length<12)throw new IllegalArgumentException("Use at least 12 characters.");char[] again=console.readPassword("Confirm password: ");if(!java.util.Arrays.equals(first,again))throw new IllegalArgumentException("Passwords did not match.");
        String password=new String(first);java.util.Arrays.fill(first,'\0');java.util.Arrays.fill(again,'\0');
        try(Connection c=DatabaseConnection.getConnection();PreparedStatement p=c.prepareStatement("INSERT INTO users(username,password_hash,role) VALUES(?,?,'ADMIN')")){p.setString(1,username);p.setString(2,PasswordUtil.hash(password));p.executeUpdate();System.out.println("Administrator account created.");}
    }
}
