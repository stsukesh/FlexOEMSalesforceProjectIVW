public class GetLeadCount {
    public Integer getLeadCount(){
        Integer leadCount=[SELECT COUNT() FROM Lead];
        return leadCount;
    }

}