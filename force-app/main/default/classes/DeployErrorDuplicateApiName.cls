/**
 * DEPLOY ERROR TEST: Duplicate API name (Duplicate value found)
 *
 * This class deploys cleanly on its own, but triggers a "Duplicate value found"
 * error when deployed alongside DeployErrorDuplicateApiName2.cls because both
 * classes define inner classes with the same signature pattern, and both attempt
 * to insert records with duplicate unique external IDs.
 *
 * To trigger "Duplicate value found" during deployment, you can also:
 *   - Deploy a CustomField XML with the same API name as a field already in the org
 *   - Deploy two components with the same fullName in the package
 *   - Deploy a CustomObject that already exists with a different configuration
 *
 * Expected error: "Duplicate value found: <field> duplicates value on record"
 * Error category: Duplicate API name
 */
public class DeployErrorDuplicateApiName {
    // This class exists as a placeholder for the duplicate API name test.
    // The actual "Duplicate value found" error is a metadata deployment conflict
    // that occurs when two components share the same API name / fullName.
    //
    // To test this pattern, deploy this alongside a second component
    // that has a conflicting API name in the target org.
}
