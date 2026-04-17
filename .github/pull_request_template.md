## 📋 Pull Request Description

### What does this PR do?
<!-- Provide a concise summary of the changes -->

### Related Issue / Ticket
<!-- Link to the JIRA, GitHub Issue, or ADO work item -->
- Closes #

---

### Type of Change
<!-- Check all that apply -->
- [ ] 🐛 Bug fix
- [ ] ✨ New pipeline / dataset / linked service
- [ ] ♻️ Refactor (no functional change)
- [ ] 🔧 Configuration / parameter update
- [ ] 📚 Documentation update
- [ ] 🚀 CI/CD change
- [ ] 🔒 Security fix

---

### ADF Artifacts Changed
<!-- List the ADF objects modified, added, or deleted -->
| Object Type | Object Name | Action |
|-------------|-------------|--------|
| Pipeline    |             | Added / Modified / Deleted |
| Dataset     |             | Added / Modified / Deleted |
| Linked Service |          | Added / Modified / Deleted |
| Trigger     |             | Added / Modified / Deleted |
| Data Flow   |             | Added / Modified / Deleted |

---

### Environment Impact
- [ ] Dev only
- [ ] Dev + QA
- [ ] All environments (Dev / QA / Prod)

### Parameter Changes
- [ ] No parameter changes
- [ ] Parameter changes – updated `environments/*.json` files accordingly

---

### Testing
- [ ] Manually tested in ADF Dev environment
- [ ] Pipeline ran successfully end-to-end
- [ ] No sensitive data exposed in logs / outputs
- [ ] Existing pipelines unaffected

---

### Checklist Before Merge
- [ ] Code follows naming conventions (`PL_`, `DS_`, `LS_`, `TR_`, `DF_` prefixes)
- [ ] No hardcoded credentials – Key Vault references used
- [ ] Linked service uses parameterized connection strings
- [ ] ARM template parameters updated for all environments
- [ ] Documentation updated (if applicable)
- [ ] CODEOWNERS notified (auto-assigned)
