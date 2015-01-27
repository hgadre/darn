// Based on the DRMAA 2 Spec GFD-R-P.194

// TODO: how to deal with fields that need to support UNSET? Make lots of
// optionals...

namespace py drmaa2
namespace java com.cloudera.darn.drmaa2.thrift

// some of the other common typedefs would require forward declarations, so
// they are included below after the definition of their necessary struct types
typedef list<string> OrderedStringList
typedef set<string> StringList
typedef map<string, string> Dictionary
typedef string AbsoluteTime
typedef i64 TimeAmount


const TimeAmount ZERO_TIME = 0
const TimeAmount INFINITE_TIME = -1
const AbsoluteTime NOW = "-2"
const string HOME_DIRECTORY = "__HOME_DIRECTORY__"
const string WORKING_DIRECTORY = "__WORKING_DIRECTORY__"
const string PARAMETRIC_INDEX = "__PARAMETRIC_INDEX__"


enum JobState {
    UNDETERMINED,
    QUEUED,
    QUEUED_HELD,
    RUNNING,
    SUSPENDED,
    REQUEUED,
    REQUEUED_HELD,
    DONE,
    FAILED
}

enum OperatingSystem {
    AIX,
    BSD,
    LINUX,
    HPUX,
    IRIX,
    MACOS,
    SUNOS,
    TRU64,
    UNIXWARE,
    WIN,
    WINNT,
    OTHER_OS
}

enum CpuArchitecture {
    ALPHA,
    ARM,
    ARM64,
    CELL,
    PARISC,
    PARISC64,
    X86,
    X64,
    IA64,
    MIPS,
    MIPS64,
    PPC,
    PPC64,
    SPARC,
    SPARC64,
    OTHER_CPU
}

enum ResourceLimitType {
    CORE_FILE_SIZE,
    CPU_TIME,
    DATA_SIZE,
    FILE_SIZE,
    OPEN_FILES,
    STACK_SIZE,
    VIRTUAL_MEMORY,
    WALLCLOCK_TIME
}

enum DrmaaEvent {
    NEW_STATE,
    MIGRATED,
    ATTRIBUTE_CHANGE
}

enum DrmaaCapability {
    ADVANCE_RESERVATION,
    RESERVE_SLOTS,
    CALLBACK,
    BULK_JOBS_MAXPARALLEL,
    JT_EMAIL,
    JT_STAGING,
    JT_DEADLINE,
    JT_MAXSLOTS,
    JT_ACCOUNTINGID,
    RT_STARTNOW,
    RT_DURATION,
    RT_MACHINEOS,
    RT_MACHINEARCH
}


struct SlotInfo {
    1: required string machineName
    2: optional i64 slots  // may be UNSET for JobInfo (see spec 5.5.7)
}

typedef list<SlotInfo> OrderedSlotInfoList

// all fields optional because this struct can be use to describe a "query" for
// filtering jobs
struct JobInfo {
    1: optional string jobId
    2: optional i64 exitStatus
    3: optional string terminatingSignal
    4: optional string annotation
    5: optional JobState jobState
    6: optional binary jobSubState
    7: optional OrderedSlotInfoList allocatedMachines
    8: optional string submissionMachine
    9: optional string jobOwner
    10: optional i64 slots
    11: optional string queueName
    12: optional TimeAmount wallclockTime
    13: optional i64 cpuTime
    14: optional AbsoluteTime submissionTime
    15: optional AbsoluteTime dispatchTime
    16: optional AbsoluteTime finishTime
}

struct ReservationInfo {
    1: required string reservationId
    2: required string reservationName
    3: optional AbsoluteTime reservedStartTime
    4: optional AbsoluteTime reservedEndTime
    5: optional StringList usersACL  // TODO: optional?
    6: required i64 reservedSlots
    7: required OrderedSlotInfoList reservedMachines
}

// required fields must be enforced by server impl (see spec 5.7)
struct JobTemplate {
    1: optional string remoteCommand
    2: optional OrderedStringList args
    3: optional bool submitAsHold
    4: optional bool rerunnable
    5: optional Dictionary jobEnvironment
    6: optional string workingDirectory
    7: optional string jobCategory  // from JobSession.jobCategories
    8: optional StringList email
    9: optional bool emailOnStarted
    10: optional bool emailOnTerminated
    11: optional string jobName
    12: optional string inputPath
    13: optional string outputPath
    14: optional string errorPath
    15: optional bool joinFiles
    16: optional string reservationId
    17: optional string queueName
    18: optional i64 minSlots
    19: optional i64 maxSlots
    20: optional i64 priority
    21: optional OrderedStringList candidateMachines
    22: optional i64 minPhysMemory
    23: optional OperatingSystem machineOS
    24: optional CpuArchitecture machineArch
    25: optional AbsoluteTime startTime
    26: optional AbsoluteTime deadlineTime
    27: optional Dictionary stageInFiles
    28: optional Dictionary stageOutFiles
    29: optional Dictionary resourceLimits
    30: optional string accountingId
}

// required fields must be enforced by server impl (see spec 5.8)
struct ReservationTemplate {
    1: optional string reservationName
    2: optional AbsoluteTime startTime
    3: optional AbsoluteTime endTime
    4: optional TimeAmount duration
    5: optional i64 minSlots
    6: optional i64 maxSlots
    7: optional string jobCategory  // http://www.drmaa.org/jobcategories/
    8: optional StringList usersACL
    9: optional OrderedStringList candidateMachines
    10: optional i64 minPhysMemory
    11: optional OperatingSystem machineOS
    12: optional CpuArchitecture machineArch
}

struct DrmaaNotification {
    1: required DrmaaEvent event
    2: required string jobId
    3: required string sessionName
    4: required JobState jobState
}

struct QueueInfo {
    1: required string name
}

typedef set<QueueInfo> QueueInfoList

struct Version {
    1: required string major
    2: required string minor
}

struct MachineInfo {
    1: required string name
    2: required bool available
    3: required i64 sockets
    4: required i64 coresPerSocket
    5: required i64 threadsPerCore
    6: required double load
    7: required i64 physMemory
    8: required i64 virtMemory
    9: required OperatingSystem machineOS
    10: required Version machineOSVersion
    11: required CpuArchitecture machineArch
}

typedef set<MachineInfo> MachineInfoList

// Interface request/response objects
// The DRMAA 2 spec defines interfaces with attributes, which are more like
// classes. As this is not supported by Thrift, I split out the attributes into
// structs and put the class "methods" as server-side functions that take a
// corresponding object.

struct ReservationSession {
    1: required string contact
    2: required string sessionName
}

struct Reservation {
    1: required string reservationId
    2: optional string sessionName
    3: optional ReservationTemplate reservationTemplate
}

typedef set<Reservation> ReservationList

struct JobSession {
    1: required string contact
    2: required string sessionName
    3: required StringList jobCategories  // http://www.drmaa.org/jobcategories/
}

struct GetStateResp {
    1: required JobState jobState
    2: optional binary jobSubState = null
}

struct Job {
    1: required string jobId
    2: optional string sessionName
    3: optional JobTemplate jobTemplate
}

typedef set<Job> JobList

struct JobArray {
    1: required string jobArrayId
    2: required JobList jobs
    3: optional string sessionName
    4: required JobTemplate jobTemplate
}

// should be a singleton on the client side (cf spec 7.1)
struct SessionManager {
    1: required string drmsName
    2: required Version drmsVersion
    3: required string drmaaName
    4: required Version drmaaVersion
}

struct DrmaaReflective {
    1: required StringList jobTemplateImplSpec
    2: required StringList jobInfoImplSpec
    3: required StringList reservationTemplateImplSpec
    4: required StringList reservationInfoImplSpec
    5: required StringList queueInfoImplSpec
    6: required StringList machineInfoImplSpec
    7: required StringList notificationImplSpec
}

// structs for stateless interfaces
struct MonitoringSession {}
struct DrmaaCallback {}

// TODO: excise expections from service spec below?
exception DeniedByDrmsException {1:string message;}
exception DrmCommunicationException {1:string message;}
exception TryLaterException {1:string message;}
exception TimeoutException {1:string message;}
exception InternalException {1:string message;}
exception InvalidArgumentException {1:string message;}
exception InvalidSessionException {1:string message;}
exception InvalidStateException {1:string message;}
exception OutOfResourceException {1:string message;}
exception UnsupportedAttributeException {1:string message;}
exception UnsupportedOperationException {1:string message;}
exception ImplementationSpecificException {1:string message; 2:i64 code;}

// RFC: Split this into the multiple constituent services?
service Drmaa2Service {
    // interface DrmaaCallback
    // TODO: is this supposed to be a separate service implemented by the client?
    void DrmaaCallback_notify(1:DrmaaNotification notification);

    // interface ReservationSession
    // throws InvalidSessionException per spec 7.1.10
    Reservation ReservationSession_getReservation(1:ReservationSession session, 2:string reservationId) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    Reservation ReservationSession_requestReservation(1:ReservationSession session, 2:ReservationTemplate reservationTemplate) throws (1:InvalidSessionException invalidSession, 2:DeniedByDrmsException deniedByDrms, 3: InvalidArgumentException invalidArg);
    ReservationList ReservationSession_getReservations(1:ReservationSession session) throws (1:InvalidSessionException invalidSession);
    void ReservationSession_close(1:ReservationSession session) throws (1:InvalidSessionException invalidSession); // optional, per spec 7.1.9

    // interface Reservation
    ReservationInfo Reservation_getInfo(1:Reservation reservation) throws (1:InvalidArgumentException invalidArg);
    void Reservation_terminate(1:Reservation reservation);

    // interface JobArray
    void JobArray_suspend(1:JobArray jobArray) throws (1:InvalidStateException invalidState);
    void JobArray_resume(1:JobArray jobArray) throws (1:InvalidStateException invalidState);
    void JobArray_hold(1:JobArray jobArray) throws (1:InvalidStateException invalidState);
    void JobArray_release(1:JobArray jobArray) throws (1:InvalidStateException invalidState);
    void JobArray_terminate(1:JobArray jobArray) throws (1:InvalidStateException invalidState);

    // interface JobSession
    // throws InvalidSessionException per spec 7.1.10
    JobList JobSession_getJobs(1:JobSession jobSession, 2:JobInfo filter) throws (1:InvalidSessionException invalidSession);
    JobArray JobSession_getJobArray(1:JobSession jobSession, 2:string jobArrayId) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    Job JobSession_runJob(1:JobSession jobSession, 2:JobTemplate jobTemplate) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    JobArray JobSession_runBulkJobs(1:JobSession jobSession, 2:JobTemplate jobTemplate, 3:i64 beginIndex, 4:i64 endIndex, 5:i64 step, 6:i64 maxParallel) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    Job JobSession_waitAnyStarted(1:JobSession jobSession, 2:JobList jobs, 3:TimeAmount timeout) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    Job JobSession_waitAnyTerminated(1:JobSession jobSession, 2:JobList jobs, 3:TimeAmount timeout) throws (1:InvalidSessionException invalidSession, 2:InvalidArgumentException invalidArg);
    void JobSession_close(1:JobSession jobSession) throws (1:InvalidSessionException invalidSession);  // optional, per spec 7.1.9

    // interface Job
    void Job_suspend(1:Job job) throws (1:InvalidStateException invalidState);
    void Job_resume(1:Job job) throws (1:InvalidStateException invalidState);
    void Job_hold(1:Job job) throws (1:InvalidStateException invalidState);
    void Job_release(1:Job job) throws (1:InvalidStateException invalidState);
    void Job_terminate(1:Job job) throws (1:InvalidStateException invalidState);
    GetStateResp Job_getState(1:Job job);
    JobInfo Job_getInfo(1:Job job);
    void Job_waitStarted(1:Job job, 2:TimeAmount timeout);
    void Job_waitTerminated(1:Job job, 2:TimeAmount timeout);

    // interface MonitoringSession (stateless)
    // these methods should respect the calling user
    ReservationList MonitoringSession_getAllReservations() throws (1:UnsupportedOperationException unsupportedOp);
    JobList MonitoringSession_getAllJobs(1:JobInfo filter);
    QueueInfoList MonitoringSession_getAllQueues(1:StringList names);
    MachineInfoList MonitoringSession_getAllMachines(1:StringList names);
    void MonitoringSession_close();  // optional, per spec 7.1.9

    // interface SessionManager
    bool SessionManager_supports(1:SessionManager sessionManager, 2:DrmaaCapability capability);
    JobSession SessionManager_createJobSession(1:SessionManager sessionManager, 2:string sessionName, 3:string contact) throws (1:InvalidArgumentException invalidArg);
    ReservationSession SessionManager_createReservationSession(1:SessionManager sessionManager, 2:string sessionName, 3:string contact) throws (1:InvalidArgumentException invalidArg, 2:UnsupportedOperationException unsupportedOp);
    JobSession SessionManager_openJobSession(1:SessionManager sessionManager, 2:string sessionName) throws (1:InvalidArgumentException invalidArg);
    ReservationSession SessionManager_openReservationSession(1:SessionManager sessionManager, 2:string sessionName) throws (1:InvalidArgumentException invalidArg, 2:UnsupportedOperationException unsupportedOp);
    MonitoringSession SessionManager_openMonitoringSession(1:SessionManager sessionManager, 2:string contact);
    void SessionManager_closeJobSession(1:SessionManager sessionManager, 2:JobSession s) throws (1:InvalidSessionException invalidSession);
    void SessionManager_closeReservationSession(1:SessionManager sessionManager, 2:ReservationSession s) throws (1:InvalidSessionException invalidSession, 2:UnsupportedOperationException unsupportedOp);
    void SessionManager_closeMonitoringSession(1:SessionManager sessionManager, 2:MonitoringSession s) throws (1:InvalidSessionException invalidSession);
    void SessionManager_destroyJobSession(1:SessionManager sessionManager, 2:string sessionName);
    void SessionManager_destroyReservationSession(1:SessionManager sessionManager, 2:string sessionName) throws (1:UnsupportedOperationException unsupportedOp);
    StringList SessionManager_getJobSessionNames(1:SessionManager sessionManager);
    StringList SessionManager_getReservationSessionNames(1:SessionManager sessionManager) throws (1:UnsupportedOperationException unsupportedOp);
    // TODO: how can Thrift support a callback mechanism?
    void SessionManager_registerEventNotification(1:SessionManager sessionManager, 2:DrmaaCallback callback) throws (1:UnsupportedOperationException unsupportedOp);

    // DRMAA reflective interface
    // TODO: Thrift does not support an "any" type; use "binary"?
    // string DrmaaReflective_getInstanceValue(1:any instance, 2:string name);
    // void DrmaaReflective_setInstanceValue(1:any instance, 2:string name, 3:string value);
    // string DrmaaReflective_describeAttribute(1:any instance, 2:string name);
}






