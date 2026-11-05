import '../models/item_model.dart';
import '../models/rental_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class MockDataService {
  static const String logoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBAN9WoyYuLBnM_oja3VoLJHzqHvud9T4UjZ0FB1ksntYvPN2oE3poEA8NPV34BIUHIHeJVDSJoJXxj-dpChHulRD3RDCVAzl-2eRBfUmZ8w149RsPDy4BTeLpUMP4yn0FcSE9yrG-3vmLWSP-VTtRHk55WjpTwdb_jZnfX1bxNvFUca5k-38nVL3qS5kZfYHKnNQaVB03El3jb3uvRlMNwq54FvtiXfwSnySF5XGvA';

  static const String currentUserAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDfi6Kin9xHZMgfA-Sjqh2L9DfuFhpe5C7HZguHN0R7eBPwLx0FjhYpfTLbf1Hwvl3k0_IrahKi2ToRNbO5Rj1FQ5GoNYkAvCkkmJTSp9v5PHYCfYZ4-fRkp2DzkZLWWLhmdBsO2VtSmkwu0Gz-oDNYbNWlGPb731UB7vjJh-4SvckeIZuYJr22CBbvIlzpH2H3LInbwOMlGLe2Yw2vf9Np62BDGAbPKrT-a9q5WqsT';

  static const String hostLucasAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAzPkl9Q3UKyHx0xTq-6ya6REUi3hVxxnaMEnIsND94mp8FjFqmc5wiPbFo9li9fk6qvFIbypDmsNELSLZjv2cyB6rZABoqY7mP0g2z9riaD-cO0vPieoPoIqaipSVJTxGlT6-_r7vt8lx2dOPkT9C0CNwB1cjKyF5BuJI9YAbf8dJRuVpL0m_0u7gcna5rx5xXj9piJhd82h5jAFHhslHHw23Dl6R-GALAAeQ7wXOn';

  static UserModel getInitialUser() {
    return UserModel(
      id: 'usr_001',
      name: 'Vinicius Pini',
      email: 'vinicius.pini@email.com',
      avatarUrl: currentUserAvatarUrl,
      kycStatus: KycStatus.pending,
      city: 'São Paulo, SP',
      neighborhood: 'Pinheiros',
      completedRentals: 14,
      rating: 4.95,
    );
  }

  static List<ItemModel> getInitialItems() {
    return [
      ItemModel(
        id: 'item_01',
        title: 'Câmera Sony A7 III + Lente 28-70mm',
        fullTitle:
            'Câmera Sony Alpha A7 III Full Frame + Lente 28-70mm + 2 Baterias',
        description: 'Ideal para gravações 4K e ensaios fotográficos',
        category: 'Eletrônicos & Câmeras',
        dailyPrice: 130.0,
        depositAmount: 1500.0,
        distanceKm: 1.2,
        distanceLabel: '1.2 km de você',
        neighborhood: 'Pinheiros, SP',
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCUbRxoduWTrTUFL7MwhfXoqp6_8_AoF74FTqUc5cif1tRTcLz-mv4JP_LzBEVPNjEXMDhzsvQhZCSnAdCrYbdRdqveff6-mq4S9pFqsGLdIXvquon9N9BE7lo5T8aKsxhaBXH0Bn-eD_Wj3BPhMhADQjJaMJFzV0o_Hzk-OwLIABIK9oGtJvZhiVfs2j94e2XvJN9RDYvPRIapvtcFi-HP8ILOuZmpEAdSQTAQ4PVw',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDIqomtN0SSxeVaimcXeNDdUVHZRWmMpwQEsn0m7IEEl739ACB7SxrROdh5a9KJ6xJQqIvuS1IurTlW3iabb9QLy-8CwaA0vdlkVfY-2AftGZ6LS7YAtU7sCYNFyPD8j1633iVzfZlKFYhe4X8EE60zVZMDWFiJAtvJmJ6Yb_w-vybQEktaktzK8ginIdYRv9Y30afsxu_9CoXSX3FbgfDC9gAsqxBx9zIb7lAaOgif',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBH_Pw7aQmsUzKvXBrJle5_3tZBsOaEyjVojkAwoN3a_YtY7VxQgAYxz60MdDuqaNEwb58f5P1_hGY7QFJtbx-TADxkTAeg_UAngxv9i9r7KIN1jJpzhs_tOpTKyGJcJCO9lib0-xUKtpj9r3j9LGmqJAT1cNH06IwBdMLL2n80VvizharrYDcMjGdCzHDgcDh6qLeiZYv2BoDABFf1Y-9hO2ipr__Psl5WxevuXKt6',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBddPv_koJKdeeFLNiviFchKS3P4OHm5VaBqvRlMaeqhUbUA5Ly4h1MxBQOVYmk8KUKtt6AWjP6H5XTJ_5GS0Ie8KKJU7-YwS8ReYxmsIHlf-z7-krYQBpriagHF0ammDcNrahDadpgyO9do7KlVzV0p8KKiIj3snwnr2uuxvd--K6hhFFaC2ACTVWi3-D52ZLxtIOAz3L56ryRKn61RKUerPXb3zMytzMiaiTzj9HK',
        ],
        ownerName: 'Lucas M.',
        ownerFullName: 'Lucas Mendes',
        ownerAvatarUrl: hostLucasAvatarUrl,
        ownerRating: 4.9,
        ownerReviewsCount: 42,
        ownerSince: 'Desde 2023',
        isKycVerified: true,
        hasEscrowGuarantee: true,
        isQuickPickup: false,
        discountPercentFor3PlusDays: 15.0,
        pickupLocation: 'Estação Faria Lima (Linha Amarela)',
        tags: ['Eletrônicos & Áudio', '4K 60fps', 'Full Frame', 'Acessórios'],
        isFavorite: false,
      ),
      ItemModel(
        id: 'item_02',
        title: 'Parafusadeira de Impacto DeWalt 20V',
        fullTitle: 'Parafusadeira de Impacto DeWalt 20V MAX Íon de Lítio',
        description: 'Acompanha 2 baterias, carregador rápido e maleta',
        category: 'Ferramentas',
        dailyPrice: 45.0,
        depositAmount: 300.0,
        distanceKm: 0.8,
        distanceLabel: '800 m de você',
        neighborhood: 'Pinheiros, SP',
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4J37R35Z-IoFAH-jV10To6kaMsOpeEr1-eRWDgTgYVR5zEHC_sf08wL7kFim8wiJ3ROCK3FBEqB2g6yWT4SsMKn99eu6km6pJ53GWyTfDFKCPcA_CJQutcqd5RJJw3A-oZJS8IAIauG-7CcT1ddlhsuFk_712z6lIFGbEK8YntwTll-8VFq7b1ROaIS9E-vQZ-SGSFBjplc69zxFhLS7uhsTc_nIUsgmur4KGS3Wh',
        ],
        ownerName: 'Carla S.',
        ownerFullName: 'Carla Souza',
        ownerAvatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=160&q=80',
        ownerRating: 5.0,
        ownerReviewsCount: 19,
        ownerSince: 'Desde 2024',
        isKycVerified: true,
        hasEscrowGuarantee: true,
        isQuickPickup: true,
        discountPercentFor3PlusDays: 10.0,
        pickupLocation: 'Vila Madalena, SP',
        tags: ['Ferramentas', 'Sem Fio', 'Bivolt'],
        isFavorite: false,
      ),
      ItemModel(
        id: 'item_03',
        title: 'Projetor Portátil Samsung The Freestyle FHD',
        fullTitle: 'Smart Projetor Portátil Samsung The Freestyle 100 polegadas',
        description: 'Smart TV integrada, auto foco e som 360 graus',
        category: 'Eletrônicos & Câmeras',
        dailyPrice: 85.0,
        depositAmount: 900.0,
        distanceKm: 2.5,
        distanceLabel: '2.5 km de você',
        neighborhood: 'Jardins, SP',
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDMX7M3O3BjBciwQC4-io_hJFHi-AoiIkws8C5k16wKXh3gQGFDzxE17qJWQw8hOO5yXL1-NazUOYX9QdcNyYVDVEJVJ6e2mdIDqC9RjJrL6BhFQ3XjxhRvDgJyykdGXJsTybCI575Sj1Xm6GBGV_8Ai1i8YNzk4MFCUcuLDroWaOgz32eFCLBYRtuuqKcZMf9GAhAKMhTyPF9LP7MhQ-K8VM924yxCUyIG7swUImU9',
        ],
        ownerName: 'Roberto G.',
        ownerFullName: 'Roberto Gomes',
        ownerAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=160&q=80',
        ownerRating: 4.8,
        ownerReviewsCount: 31,
        ownerSince: 'Desde 2022',
        isKycVerified: true,
        hasEscrowGuarantee: true,
        isQuickPickup: false,
        discountPercentFor3PlusDays: 15.0,
        pickupLocation: 'Cerqueira César, SP',
        tags: ['Home Cinema', 'Wi-Fi', 'Bluetooth'],
        isFavorite: false,
      ),
      ItemModel(
        id: 'item_04',
        title: 'Tenda Gazebo Dobrável 3x3m para Festas',
        fullTitle: 'Tenda Gazebo Sanfonada Articulada 3x3m Branca Impermeável',
        description:
            'Montagem rápida articulada, proteção UV e capa de transporte',
        category: 'Festas & Eventos',
        dailyPrice: 60.0,
        depositAmount: 250.0,
        distanceKm: 3.1,
        distanceLabel: '3.1 km de você',
        neighborhood: 'Alto de Pinheiros, SP',
        images: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDetGdlUzOuit-9ups0jFE2TKfG9mlXTip_d75mZ9oE2IZZUQVNexmzTnlruCC6TTxCdwQwj--o4L6nUPV9K018q9KyCZgplwkLSYSeAK9tJJrdR8Mt3WI_9fpT3eXaota7IHL1IMjlrwYsJx45uPhusYyUsVpOE02TxiHOb_DFaH2DE2O0GUc8ITdsnq4Y_2NS3RN6uXd7A3W3CH2O8L1STq9CH90Pa-1fogtQ1-v7',
        ],
        ownerName: 'Ana P.',
        ownerFullName: 'Ana Paula Rocha',
        ownerAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=160&q=80',
        ownerRating: 4.9,
        ownerReviewsCount: 15,
        ownerSince: 'Desde 2023',
        isKycVerified: true,
        hasEscrowGuarantee: true,
        isQuickPickup: false,
        discountPercentFor3PlusDays: 20.0,
        pickupLocation: 'Alto de Pinheiros, SP',
        tags: ['Eventos', 'Fácil Montagem', 'Proteção Solar'],
        isFavorite: false,
      ),
    ];
  }

  static RentalModel getInitialRental() {
    return RentalModel(
      id: '#1020',
      itemId: 'item_01',
      itemTitle: 'Sony Alpha A7 IV + Lente 24-70mm',
      itemImageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCD82IRbt6wM9tr5cIS9Ag3WLjy5fnp6lqCNc8CS2wEnJMH0YLT0-KyaKaGvmLNy-fagPBgmiF1kwhGtuY-gHgiznYnFRg3OLovP98w6HBqDJwbcGsJgHXLKWDighrcmANdtCSaUjssQzNsSzMUQSBcIg1WAQdCbbKq3GYRDUXwTEhbOZ3NwfXuAPDDPs2ITQaauH1Rmrk13EU1xkwgxahUiNeZpeaiOvCeFnWoXwtT',
      ownerName: 'Lucas M.',
      startDate: DateTime(2026, 10, 18, 10, 0),
      endDate: DateTime(2026, 10, 20, 19, 0),
      daysCount: 3,
      dailyRate: 130.0,
      discountAmount: 58.50,
      platformFee: 39.00,
      freightType: FreightType.pickup,
      depositAmount: 1500.0,
      status: RentalStatus.paidConfirmed,
      paymentMethod: PaymentMethodType.creditCard,
      pinCode: '849-210',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      inspectionPhotos: [
        InspectionPhoto(
          id: 'insp_1',
          title: 'Corpo da Câmera',
          label: 'Corpo',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA3AYhwcsyZXlgFt3pVG378dd6viAU1NzdDx_XAV7h92MhiypnhRHhbSIVg7DmCWJ2TDTJJJz8termXb4TI4TEOJunsE7kER-n8F_zVExHirv15v7421GRpCtScsnN4qMHzJRDqS7DhOB9KOn-qSR1I6cmABaJIx5cOSk1OPL1zBnJdbbaGEm_cTTSS_NbOJkbA4a2N7QKgDP4IGPuuF_JgdW0FdEYAbzWxcVNKKe7x',
          timestamp: DateTime.now(),
        ),
        InspectionPhoto(
          id: 'insp_2',
          title: 'Lente Óptica',
          label: 'Lente',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuA5uy1PLtGzRGodfws5ERnZSO8ibc86DhhoYwHHMEjlJUMv3X-9uYoyOV1sY6UaeFHQXLRjk1DprQtIipBT47wIFK0p9WIYTr7325wMZrKOl1L4X-PdGZCWkGqjAGe8T5YyyLvsls8ZBkDXEC5E7g2Kb9cYnHU5baIKLdF3-nxg60jAfgG0O4Yln7wqdUwn0jUxhk6xWdqAdc-TRZHfWZp54d6axGJ0ghpfpf3fdsMi',
          timestamp: DateTime.now(),
        ),
        InspectionPhoto(
          id: 'insp_3',
          title: 'Kit Extra de Baterias',
          label: 'Kit Extra',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDV6jklRi95wdOp23bY2QMU9KnJEaWQAKloDTljnnZdT5UvIgG-OsmwDKjc2raRd2DjzYlZWE5gt8CTaelDmAYiW0-RfUA52HC98V8KA15Ez7pewIqb4s7UH5SVIQ_K3n9l-5lv2BJegTHHjOyLm_5GEIbFJ-DoSm_w0folXOq3yHYMlhiz-HrFUh6iaFGin0qqBt3kIWfST82waI7SZ-spOsNJAnSZgDZ3aKZQDlAM',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  static List<ChatMessage> getInitialMessages() {
    return [
      ChatMessage(
        id: 'msg_1',
        type: MessageType.host,
        senderName: 'Lucas M.',
        senderInitials: 'LM',
        text:
            'Olá! Reserva confirmada. A câmera já está com a bateria 100% carregada e no case de proteção.',
        timestamp: DateTime(2026, 10, 17, 14, 22),
      ),
      ChatMessage(
        id: 'msg_2',
        type: MessageType.inspectionCard,
        senderName: 'Sistema AlugaTudo',
        text:
            'Lucas registrou o estado atual de conservação para o termo de entrega:',
        timestamp: DateTime(2026, 10, 17, 14, 23),
        photoUrls: [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA3AYhwcsyZXlgFt3pVG378dd6viAU1NzdDx_XAV7h92MhiypnhRHhbSIVg7DmCWJ2TDTJJJz8termXb4TI4TEOJunsE7kER-n8F_zVExHirv15v7421GRpCtScsnN4qMHzJRDqS7DhOB9KOn-qSR1I6cmABaJIx5cOSk1OPL1zBnJdbbaGEm_cTTSS_NbOJkbA4a2N7QKgDP4IGPuuF_JgdW0FdEYAbzWxcVNKKe7x',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5uy1PLtGzRGodfws5ERnZSO8ibc86DhhoYwHHMEjlJUMv3X-9uYoyOV1sY6UaeFHQXLRjk1DprQtIipBT47wIFK0p9WIYTr7325wMZrKOl1L4X-PdGZCWkGqjAGe8T5YyyLvsls8ZBkDXEC5E7g2Kb9cYnHU5baIKLdF3-nxg60jAfgG0O4Yln7wqdUwn0jUxhk6xWdqAdc-TRZHfWZp54d6axGJ0ghpfpf3fdsMi',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDV6jklRi95wdOp23bY2QMU9KnJEaWQAKloDTljnnZdT5UvIgG-OsmwDKjc2raRd2DjzYlZWE5gt8CTaelDmAYiW0-RfUA52HC98V8KA15Ez7pewIqb4s7UH5SVIQ_K3n9l-5lv2BJegTHHjOyLm_5GEIbFJ-DoSm_w0folXOq3yHYMlhiz-HrFUh6iaFGin0qqBt3kIWfST82waI7SZ-spOsNJAnSZgDZ3aKZQDlAM',
        ],
      ),
      ChatMessage(
        id: 'msg_3',
        type: MessageType.user,
        senderName: 'Vinicius Pini',
        text:
            'Perfeito Lucas! Vou retirar às 10h na estação conforme combinado.',
        timestamp: DateTime(2026, 10, 17, 14, 26),
      ),
      ChatMessage(
        id: 'msg_4',
        type: MessageType.system,
        senderName: 'Instrução de Retirada',
        text:
            'Lembre-se de apresentar seu código PIN de 6 dígitos no momento da entrega para validar o início oficial do aluguel.',
        timestamp: DateTime(2026, 10, 17, 14, 27),
      ),
    ];
  }
}
