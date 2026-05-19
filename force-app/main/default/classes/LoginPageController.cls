public with sharing class LoginPageController {
    /**
     * Authenticates a user with username and password
     * @param username The username to authenticate
     * @param password The password to authenticate
     * @return Map containing success status and message
     */
    @AuraEnabled
    public static Map<String, Object> authenticateUser(
        String username,
        String password
    ) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            // Validate input parameters
            if (String.isBlank(username) || String.isBlank(password)) {
                result.put('success', false);
                result.put('message', 'Username and password are required');
                return result;
            }

            // Query for user by username
            List<User> users = [
                SELECT Id, Name, Email, IsActive, Username
                FROM User
                WHERE Username = :username AND IsActive = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (users.isEmpty()) {
                result.put('success', false);
                result.put('message', 'Invalid username or password');
                return result;
            }

            User authenticatedUser = users[0];

            // Note: Actual password verification would be handled by Salesforce authentication
            // This is a simplified example for demonstration purposes
            // In production, use proper authentication mechanisms like Site.login() or Auth.SessionManagement

            result.put('success', true);
            result.put('message', 'Login successful');
            result.put('userId', authenticatedUser.Id);
            result.put('userName', authenticatedUser.Name);
            result.put('userEmail', authenticatedUser.Email);
        } catch (Exception e) {
            result.put('success', false);
            result.put(
                'message',
                'An error occurred during authentication: ' + e.getMessage()
            );
        }

        return result;
    }

    /**
     * Validates if a username exists in the system
     * @param username The username to validate
     * @return Boolean indicating if username exists
     */
    @AuraEnabled(cacheable=true)
    public static Boolean validateUsername(String username) {
        if (String.isBlank(username)) {
            return false;
        }

        Integer userCount = [
            SELECT COUNT()
            FROM User
            WHERE Username = :username AND IsActive = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return userCount > 0;
    }
}
