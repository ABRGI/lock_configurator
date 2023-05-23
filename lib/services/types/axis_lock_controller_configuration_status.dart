class AxisLockControllerConfigurationStatus {
  bool getAccessPoints;
  bool setAccessPoints;
  bool getIdPoints;
  bool setIdPoints;
  bool setAccessProfiles;
  bool setTemporaryLockCodes;

  AxisLockControllerConfigurationStatus(
      {this.getAccessPoints = false,
      this.setAccessPoints = false,
      this.getIdPoints = false,
      this.setIdPoints = false,
      this.setAccessProfiles = false,
      this.setTemporaryLockCodes = false});

  get isConfigComplete {
    return getAccessPoints &&
        setAccessPoints &&
        getIdPoints &&
        setIdPoints &&
        setAccessProfiles;
  }
}
