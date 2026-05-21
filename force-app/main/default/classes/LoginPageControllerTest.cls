/**
 * @description Test class for LoginPageController
 * Tests authentication and username validation functionality
 * Covers positive, negative, and edge cases
 */
@isTest
private class LoginPageControllerTest {
    private static final String VALID_USERNAME = 'testuser@examplelogintest.com';
    private static final String VALID_PASSWORD = 'TestPassword123!';
    private static final String INVALID_USERNAME = 'nonexistent@examplelogintest.com';
    private static final String INACTIVE_USERNAME = 'inactive@examplelogintest.com';

    /**
     * @description Setup test data - creates active and inactive users
     */
    @TestSetup
    static void setupTestData() {
        // Create test user profile - using Standard User profile
        Profile standardProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        // Create active test user
        User activeUser = new User(
            Username = VALID_USERNAME,
            Email = VALID_USERNAME,
            LastName = 'Test User',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser;

        // Create inactive test user
        User inactiveUser = new User(
            Username = INACTIVE_USERNAME,
            Email = INACTIVE_USERNAME,
            LastName = 'Inactive User',
            Alias = 'iuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser;
    }

    /**
     * @description Test successful authentication with valid username and password
     * Verifies that active user can authenticate and returns correct user data
     */
    @isTest
    static void shouldAuthenticateSuccessfully_WhenValidCredentials() {
        // Given - Query the user created in @TestSetup
        User testUser = [
            SELECT Id, Username, Email
            FROM User
            WHERE Username = :VALID_USERNAME
            LIMIT 1
        ];
        String username = testUser.Username;
        String password = VALID_PASSWORD;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            username,
            password
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            true,
            result.get('success'),
            'Authentication should succeed with valid credentials'
        );
        Assert.areEqual(
            'Login successful',
            result.get('message'),
            'Success message should be returned'
        );
        Assert.isNotNull(result.get('userId'), 'User ID should be returned');
        Assert.isNotNull(
            result.get('userName'),
            'User name should be returned'
        );
        Assert.isNotNull(
            result.get('userEmail'),
            'User email should be returned'
        );
        Assert.areEqual(
            testUser.Email,
            result.get('userEmail'),
            'Email should match the test user email'
        );
    }

    /**
     * @description Test authentication fails when username is blank
     * Verifies proper validation of required username parameter
     */
    @isTest
    static void shouldFailAuthentication_WhenUsernameIsBlank() {
        // Given
        String blankUsername = '';
        String password = VALID_PASSWORD;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            blankUsername,
            password
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail with blank username'
        );
        Assert.areEqual(
            'Username and password are required',
            result.get('message'),
            'Validation error message should be returned'
        );
    }

    /**
     * @description Test authentication fails when username is null
     * Verifies null handling for username parameter
     */
    @isTest
    static void shouldFailAuthentication_WhenUsernameIsNull() {
        // Given
        String nullUsername = null;
        String password = VALID_PASSWORD;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            nullUsername,
            password
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail with null username'
        );
        Assert.areEqual(
            'Username and password are required',
            result.get('message'),
            'Validation error message should be returned'
        );
    }

    /**
     * @description Test authentication fails when password is blank
     * Verifies proper validation of required password parameter
     */
    @isTest
    static void shouldFailAuthentication_WhenPasswordIsBlank() {
        // Given
        String username = VALID_USERNAME;
        String blankPassword = '';

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            username,
            blankPassword
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail with blank password'
        );
        Assert.areEqual(
            'Username and password are required',
            result.get('message'),
            'Validation error message should be returned'
        );
    }

    /**
     * @description Test authentication fails when password is null
     * Verifies null handling for password parameter
     */
    @isTest
    static void shouldFailAuthentication_WhenPasswordIsNull() {
        // Given
        String username = VALID_USERNAME;
        String nullPassword = null;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            username,
            nullPassword
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail with null password'
        );
        Assert.areEqual(
            'Username and password are required',
            result.get('message'),
            'Validation error message should be returned'
        );
    }

    /**
     * @description Test authentication fails when both username and password are blank
     * Verifies validation handles multiple blank parameters
     */
    @isTest
    static void shouldFailAuthentication_WhenBothCredentialsAreBlank() {
        // Given
        String blankUsername = '';
        String blankPassword = '';

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            blankUsername,
            blankPassword
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail with both blank credentials'
        );
        Assert.areEqual(
            'Username and password are required',
            result.get('message'),
            'Validation error message should be returned'
        );
    }

    /**
     * @description Test authentication fails for non-existent username
     * Verifies security - doesn't reveal if username exists or password is wrong
     */
    @isTest
    static void shouldFailAuthentication_WhenUsernameDoesNotExist() {
        // Given
        String nonExistentUsername = INVALID_USERNAME;
        String password = VALID_PASSWORD;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            nonExistentUsername,
            password
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail for non-existent username'
        );
        Assert.areEqual(
            'Invalid username or password',
            result.get('message'),
            'Generic error message should be returned for security'
        );
    }

    /**
     * @description Test authentication fails for inactive user
     * Verifies that only active users can authenticate
     */
    @isTest
    static void shouldFailAuthentication_WhenUserIsInactive() {
        // Given
        String inactiveUsername = INACTIVE_USERNAME;
        String password = VALID_PASSWORD;

        // When
        Test.startTest();
        Map<String, Object> result = LoginPageController.authenticateUser(
            inactiveUsername,
            password
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result.get('success'),
            'Authentication should fail for inactive user'
        );
        Assert.areEqual(
            'Invalid username or password',
            result.get('message'),
            'Generic error message should be returned'
        );
    }

    /**
     * @description Test validateUsername returns true for existing active username
     * Verifies username validation for active users
     */
    @isTest
    static void shouldReturnTrue_WhenValidatingExistingActiveUsername() {
        // Given - Query the user created in @TestSetup
        User testUser = [
            SELECT Id, Username
            FROM User
            WHERE Username = :VALID_USERNAME
            LIMIT 1
        ];
        String existingUsername = testUser.Username;

        // When
        Test.startTest();
        Boolean result = LoginPageController.validateUsername(existingUsername);
        Test.stopTest();

        // Then
        Assert.areEqual(
            true,
            result,
            'Validation should return true for existing active username'
        );
    }

    /**
     * @description Test validateUsername returns false for blank username
     * Verifies validation handles blank input
     */
    @isTest
    static void shouldReturnFalse_WhenValidatingBlankUsername() {
        // Given
        String blankUsername = '';

        // When
        Test.startTest();
        Boolean result = LoginPageController.validateUsername(blankUsername);
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result,
            'Validation should return false for blank username'
        );
    }

    /**
     * @description Test validateUsername returns false for null username
     * Verifies validation handles null input
     */
    @isTest
    static void shouldReturnFalse_WhenValidatingNullUsername() {
        // Given
        String nullUsername = null;

        // When
        Test.startTest();
        Boolean result = LoginPageController.validateUsername(nullUsername);
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result,
            'Validation should return false for null username'
        );
    }

    /**
     * @description Test validateUsername returns false for non-existent username
     * Verifies validation correctly identifies non-existent users
     */
    @isTest
    static void shouldReturnFalse_WhenValidatingNonExistentUsername() {
        // Given
        String nonExistentUsername = INVALID_USERNAME;

        // When
        Test.startTest();
        Boolean result = LoginPageController.validateUsername(
            nonExistentUsername
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result,
            'Validation should return false for non-existent username'
        );
    }

    /**
     * @description Test validateUsername returns false for inactive user
     * Verifies validation only considers active users
     */
    @isTest
    static void shouldReturnFalse_WhenValidatingInactiveUsername() {
        // Given
        String inactiveUsername = INACTIVE_USERNAME;

        // When
        Test.startTest();
        Boolean result = LoginPageController.validateUsername(inactiveUsername);
        Test.stopTest();

        // Then
        Assert.areEqual(
            false,
            result,
            'Validation should return false for inactive username'
        );
    }
}
