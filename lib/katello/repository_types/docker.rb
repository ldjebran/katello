Katello::RepositoryTypeManager.register(::Katello::Repository::DOCKER_TYPE) do
  service_class Katello::Pulp::Repository::Docker

  content_type Katello::DockerManifest, :priority => 1, :pulp2_service_class => ::Katello::Pulp::DockerManifest
  content_type Katello::DockerManifestList, :priority => 2, :pulp2_service_class => ::Katello::Pulp::DockerManifestList
  content_type Katello::DockerTag, :priority => 3, :pulp2_service_class => ::Katello::Pulp::DockerTag
end
