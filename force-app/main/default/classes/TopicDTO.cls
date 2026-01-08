/**
 * @name: TopicDTO
 * @author: Sukesh Subash
 * @date: 06/01/2026
 * @description: Data transfer object for Topic payloads between Apex and LWC.
 * @test class: TopicServiceTest
 */
public with sharing class TopicDTO {

    /**
     * Canonical Topic representation used by LWCs
     */
    public class TopicItem {
        public Id id;
        public String name;
        public Boolean isFollowed;

        public TopicItem(Id id, String name) {
            this.id = id;
            this.name = name;
            this.isFollowed = false;
        }
    }
}