public with sharing class SecondQueueableClass implements Queueable {
    public void execute(QueueableContext context){
        Integer depth = AsyncInfo.getCurrentQueueableStackDepth();
        if(depth >= AsyncInfo.getMaximumQueueableStackDepth()) return;
        System.debug('!!!!Second Queueable ' + depth);
        System.enqueueJob(new SecondQueueableClass());
    }
}