import 'dart:convert';
import 'package:flutter_invoice_app/models/alerts/alert_instance_model.dart';
import 'package:flutter_invoice_app/models/user/user_model.dart';
import 'package:flutter_invoice_app/services/user/user_service.dart';
import 'package:http/http.dart' as http;

class EmailNotificationService {
  final UserService _userService;
  final String _apiKey;
  final String _apiUrl;
  
  EmailNotificationService({
    required UserService userService,
    required String apiKey,
    required String apiUrl,
  }) : _userService = userService,
       _apiKey = apiKey,
       _apiUrl = apiUrl;
  
  Future<bool> sendAlertNotification(AlertInstance alert) async {
    try {
      final user = await _userService.getCurrentUser();
      if (user == null || user.email.isEmpty) {
        return false;
      }
      
      final response = await _sendEmail(
        to: user.email,
        subject: 'GST Alert: ${_getSeverityText(alert.severity)} - ${alert.metricType.toString().split('.').last}',
        body: _buildEmailBody(alert, user),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending email notification: $e');
      return false;
    }
  }
  
  Future<bool> sendReconciliationReport(String reportId, String reportName, String reportUrl) async {
    try {
      final user = await _userService.getCurrentUser();
      if (user == null || user.email.isEmpty) {
        return false;
      }
      
      final response = await _sendEmail(
        to: user.email,
        subject: 'GST Reconciliation Report: $reportName',
        body: _buildReportEmailBody(reportName, reportUrl, user),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending report email: $e');
      return false;
    }
  }
  
  Future<http.Response> _sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final url = Uri.parse(_apiUrl);
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'to': to,
        'subject': subject,
        'html': body,
      }),
    );
    
    return response;
  }
  
  String _buildEmailBody(AlertInstance alert, User user) {
    return '''
    <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #f8f9fa; padding: 20px; text-align: center; }
          .content { padding: 20px; }
          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; }
          .alert-info { background-color: #cce5ff; border: 1px solid #b8daff; padding: 15px; border-radius: 4px; }
          .alert-warning { background-color: #fff3cd; border: 1px solid #ffeeba; padding: 15px; border-radius: 4px; }
          .alert-critical { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; }
          .btn { display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 4px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>GST Compliance Alert</h2>
          </div>
          <div class="content">
            <p>Hello ${user.name},</p>
            <p>This is an automated alert from your GST Compliance Monitoring System.</p>
            
            <div class="alert-${_getSeverityClass(alert.severity)}">
              <h3>${_getSeverityText(alert.severity)} Alert</h3>
              <p>${alert.message}</p>
              <p><strong>Date & Time:</strong> ${alert.createdAt.toString()}</p>
            </div>
            
            <p>Please log in to your GST application to review this alert and take appropriate action.</p>
            
            <p style="text-align: center; margin-top: 30px;">
              <a href="#" class="btn">View Alert Details</a>
            </p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>&copy; ${DateTime.now().year} GST Compliance System</p>
          </div>
        </div>
      </body>
    </html>
    ''';
  }
  
  String _buildReportEmailBody(String reportName, String reportUrl, User user) {
    return '''
    <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #f8f9fa; padding: 20px; text-align: center; }
          .content { padding: 20px; }
          .footer { background-color: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; }
          .report-info { background-color: #e2f0d9; border: 1px solid #c6e0b4; padding: 15px; border-radius: 4px; }
          .btn { display: inline-block; padding: 10px 20px; background-color: #28a745; color: white; text-decoration: none; border-radius: 4px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>GST Reconciliation Report</h2>
          </div>
          <div class="content">
            <p>Hello ${user.name},</p>
            <p>Your requested GST reconciliation report is ready.</p>
            
            <div class="report-info">
              <h3>$reportName</h3>
              <p><strong>Generated on:</strong> ${DateTime.now().toString()}</p>
            </div>
            
            <p>You can view or download the report by clicking the button below:</p>
            
            <p style="text-align: center; margin-top: 30px;">
              <a href="$reportUrl" class="btn">View Report</a>
            </p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>&copy; ${DateTime.now().year} GST Compliance System</p>
          </div>
        </div>
      </body>
    </html>
    ''';
  }
  
  String _getSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return 'Information';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
  
  String _getSeverityClass(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return 'info';
      case AlertSeverity.warning:
        return 'warning';
      case AlertSeverity.critical:
        return 'critical';
    }
  }
}
